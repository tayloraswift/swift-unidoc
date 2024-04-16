import HTTP
import NIOCore
import NIOHPACK
import NIOHTTP2

extension HTTP.Client2
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let channel:any Channel
        /// The hostname of the remote peer.
        public
        let remote:String

        @inlinable internal
        init(channel:any Channel, remote:String)
        {
            self.channel = channel
            self.remote = remote
        }
    }
}
@available(*, unavailable, message: """
    HTTP.Client2.Connection is not Sendable, use 'fetch(reducing:into:with:)' \
    to make requests in parallel.
    """)
extension HTTP.Client2.Connection:Sendable
{
}
extension HTTP.Client2.Connection
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
    func buffer(bytes:ArraySlice<UInt8>) -> ByteBuffer
    {
        self.channel.allocator.buffer(bytes: bytes)
    }
}
extension HTTP.Client2.Connection
{
    public
    func fetch(_ request:__owned HPACKHeaders) async throws -> HTTP.Client2.Facet
    {
        try await self.fetch(.init(headers: request, body: nil))
    }
    public
    func fetch(_ request:__owned HTTP.Client2.Request,
        timeout:Duration = .seconds(15)) async throws -> HTTP.Client2.Facet
    {
        try await self.fetch(reducing: [request], into: .init(), timeout: timeout) { $0 = $1 }
    }

    public
    func fetch(_ batch:__owned [HTTP.Client2.Request]) async throws -> [HTTP.Client2.Facet]
    {
        try await self.fetch(reducing: batch, into: []) { $0.append($1) }
    }

    @inlinable public
    func fetch<Response>(reducing batch:__owned [HTTP.Client2.Request],
        into initial:__owned Response,
        timeout:Duration = .seconds(15),
        with combine:(inout Response, HTTP.Client2.Facet) throws -> ()) async throws -> Response
    {
        if  batch.isEmpty
        {
            return initial
        }

        var response:Response = initial

        var source:AsyncThrowingStream<HTTP.Client2.Facet, any Error>.Continuation?
        let stream:AsyncThrowingStream<HTTP.Client2.Facet, any Error> = .init
        {
            source = $0
        }
        if  let source
        {
            async
            let _:Void =
            {
                try await Task.sleep(for: timeout)
                source.finish(throwing: HTTP.RequestTimeoutError.init())
            }()

            let awaiting:Int = batch.count
            var facets:AsyncThrowingStream<HTTP.Client2.Facet, any Error>.Iterator =
                stream.makeAsyncIterator()

            self.channel.writeAndFlush((source, batch)).whenFailure
            {
                source.finish(throwing: $0)
            }

            for _:Int in 0 ..< awaiting
            {
                if  let facet:HTTP.Client2.Facet = try await facets.next()
                {
                    try combine(&response, facet)
                }
                else
                {
                    throw HTTP.Client2.UnexpectedStreamTerminationError.init()
                }
            }
        }

        return response
    }
}
