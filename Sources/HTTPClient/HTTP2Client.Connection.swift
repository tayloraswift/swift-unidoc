import NIOCore
import NIOHPACK
import NIOHTTP2

extension HTTP2Client
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let channel:any Channel

        @inlinable internal
        init(channel:any Channel)
        {
            self.channel = channel
        }
    }
}
@available(*, unavailable, message: """
    HTTP2Client.Connection is not Sendable, use 'fetch(reducing:into:with:)' \
    to make requests in parallel.
    """)
extension HTTP2Client.Connection:Sendable
{
}
extension HTTP2Client.Connection
{
    @inlinable public
    func buffer(string:Substring) -> ByteBuffer
    {
        self.channel.allocator.buffer(substring: string)
    }

    @inlinable public
    func buffer(string:String) -> ByteBuffer
    {
        self.channel.allocator.buffer(string: string)
    }

    @inlinable public
    func buffer(bytes:[UInt8]) -> ByteBuffer
    {
        self.channel.allocator.buffer(bytes: bytes)
    }
}
extension HTTP2Client.Connection
{
    public
    func fetch(_ request:__owned HPACKHeaders) async throws -> HTTP2Client.Facet
    {
        try await self.fetch(.init(headers: request, body: nil))
    }
    public
    func fetch(_ request:__owned HTTP2Client.Request) async throws -> HTTP2Client.Facet
    {
        try await self.fetch(reducing: [request], into: .init()) { $0 = $1 }
    }

    public
    func fetch(_ batch:__owned [HTTP2Client.Request]) async throws -> [HTTP2Client.Facet]
    {
        try await self.fetch(reducing: batch, into: []) { $0.append($1) }
    }

    @inlinable public
    func fetch<Response>(reducing batch:__owned [HTTP2Client.Request],
        into initial:__owned Response,
        with combine:(inout Response, HTTP2Client.Facet) throws -> ()) async throws -> Response
    {
        if  batch.isEmpty
        {
            return initial
        }

        var response:Response = initial

        var source:AsyncThrowingStream<HTTP2Client.Facet, any Error>.Continuation?
        let stream:AsyncThrowingStream<HTTP2Client.Facet, any Error> = .init
        {
            source = $0
        }
        if  let source
        {
            async
            let _:Void =
            {
                try await Task.sleep(for: .seconds(15))
                source.finish(throwing: HTTP2Client.RequestTimeoutError.init())
            }()

            let awaiting:Int = batch.count
            var facets:AsyncThrowingStream<HTTP2Client.Facet, any Error>.Iterator =
                stream.makeAsyncIterator()

            channel.writeAndFlush((source, batch)).whenFailure
            {
                source.finish(throwing: $0)
            }

            for _:Int in 0 ..< awaiting
            {
                if  let facet:HTTP2Client.Facet = try await facets.next()
                {
                    try combine(&response, facet)
                }
                else
                {
                    throw HTTP2Client.UnexpectedStreamTerminationError.init()
                }
            }
        }

        return response
    }
}
