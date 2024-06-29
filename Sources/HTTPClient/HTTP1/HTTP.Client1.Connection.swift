import HTTP
import NIOCore

extension HTTP.Client1
{
    @frozen public
    struct Connection
    {
        @usableFromInline
        let channel:any Channel
        /// The hostname of the remote peer.
        public
        let remote:String

        @inlinable
        init(channel:any Channel, remote:String)
        {
            self.channel = channel
            self.remote = remote
        }
    }
}
@available(*, unavailable, message: """
    HTTP.Client1.Connection is not Sendable.
    """)
extension HTTP.Client1.Connection:Sendable
{
}
extension HTTP.Client1.Connection:HTTP.ClientConnection
{
    @inlinable public
    func buffer(string:Substring) -> ByteBuffer
    {
        self.channel.allocator.buffer(substring: string)
    }

    @inlinable public
    func buffer(bytes:ArraySlice<UInt8>) -> ByteBuffer
    {
        self.channel.allocator.buffer(bytes: bytes)
    }
}
extension HTTP.Client1.Connection
{
    //  TODO: we could use the `content-length` header to avoid reallocating the destination
    //  buffer.
    public
    func fetch(_ request:__owned HTTP.Client1.Request,
        timeout:Duration = .seconds(15)) async throws -> HTTP.Client1.Facet
    {
        try await withThrowingTaskGroup(of: HTTP.Client1.Facet.self)
        {
            (tasks:inout ThrowingTaskGroup<HTTP.Client1.Facet, any Error>) in

            let channel:any Channel = self.channel

            //  https://forums.swift.org/t/writing-a-checkedcontinuation-to-a-channel-without-leaking/68745/
            tasks.addTask
            {
                let promise:
                    EventLoopPromise<HTTP.Client1.Facet> = channel.eventLoop.makePromise()

                channel.writeAndFlush((promise, request)).whenFailure
                {
                    // don’t leak the promise!
                    promise.fail($0)
                }

                return try await promise.futureResult.get()
            }
            tasks.addTask
            {
                try await Task.sleep(for: timeout)
                throw HTTP.RequestTimeoutError.init()
            }

            guard
            let facet:HTTP.Client1.Facet = try await tasks.next()
            else
            {
                throw HTTP.RequestTimeoutError.init()
            }

            tasks.cancelAll()
            return facet
        }
    }
}
