import HTTP
import NIOCore

extension HTTP1Client
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
    HTTP1Client.Connection is not Sendable.
    """)
extension HTTP1Client.Connection:Sendable
{
}
extension HTTP1Client.Connection
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
extension HTTP1Client.Connection
{
    public
    func fetch(_ request:__owned HTTP1Client.Request) async throws -> HTTP1Client.Facet
    {
        try await withThrowingTaskGroup(of: HTTP1Client.Facet.self)
        {
            (tasks:inout ThrowingTaskGroup<HTTP1Client.Facet, any Error>) in

            let channel:any Channel = self.channel

            tasks.addTask
            {
                try await withCheckedThrowingContinuation
                {
                    (promise:CheckedContinuation<HTTP1Client.Facet, Error>) in

                    channel.writeAndFlush((promise, request)).whenFailure
                    {
                        promise.resume(throwing: $0)
                    }
                }
            }
            tasks.addTask
            {
                try await Task.sleep(for: .seconds(15))
                throw HTTP.RequestTimeoutError.init()
            }

            guard
            let facet:HTTP1Client.Facet = try await tasks.next()
            else
            {
                throw HTTP.RequestTimeoutError.init()
            }

            tasks.cancelAll()
            return facet
        }
    }
}
