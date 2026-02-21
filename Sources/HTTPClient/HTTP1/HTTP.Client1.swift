import NIOCore
import NIOPosix
import NIOSSL

extension HTTP {
    /// An HTTP/1.1 client associated with a single ``remote`` host.
    @frozen public struct Client1: @unchecked Sendable {
        @usableFromInline let _bootstrap: ClientBootstrap

        /// The hostname of the remote service.
        public let remote: String

        private init(_bootstrap: ClientBootstrap, remote: String) {
            self._bootstrap = _bootstrap
            self.remote = remote
        }
    }
}
extension HTTP.Client1 {
    public init(threads: MultiThreadedEventLoopGroup, niossl: NIOSSLContext?, remote: String) {
        let _bootstrap: ClientBootstrap = .init(group: threads)
            .connectTimeout(.seconds(3))
            .channelInitializer {
                (channel: any Channel) in

                channel.eventLoop.makeCompletedFuture {
                    if  let niossl: NIOSSLContext {
                        let tlsHandler: NIOSSLClientHandler = try .init(
                            context: niossl,
                            serverHostname: remote
                        )
                        try channel.pipeline.syncOperations.addHandler(tlsHandler)
                    }

                    try channel.pipeline.syncOperations.addHTTPClientHandlers()
                    try channel.pipeline.syncOperations.addHandler(InterfaceHandler.init())
                }
            }

        self.init(_bootstrap: _bootstrap, remote: remote)
    }
}
extension HTTP.Client1: HTTP.Client {
    /// Connect to the ``remote`` host and perform the given operation.
    @inlinable public func connect<T>(
        port: Int,
        with body: (Connection) async throws -> T
    ) async throws -> T {
        let channel: any Channel = try await self._bootstrap.connect(
            host: self.remote,
            port: port
        ).get()

        defer {
            channel.close(promise: nil)
        }

        return try await body(Connection.init(channel: channel, remote: self.remote))
    }
}
