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
    func buffer(_ body:HTTP.Resource.Content.Body) -> ByteBuffer
    {
        switch body
        {
        case .buffer(let buffer):   buffer
        case .binary(let bytes):    self.channel.allocator.buffer(bytes: bytes)
        case .string(let string):   self.channel.allocator.buffer(string: string)
        }
    }
}
extension HTTP1Client.Connection
{
    //  TODO: we could use the `content-length` header to avoid reallocating the destination
    //  buffer.
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
