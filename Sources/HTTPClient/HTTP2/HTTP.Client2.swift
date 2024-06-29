import NIOCore
import NIOHPACK
import NIOHTTP2
import NIOPosix
import NIOSSL

@available(*, deprecated, renamed: "HTTP.Client1")
public
typealias HTTP2Client = HTTP.Client2

extension HTTP
{
    /// An HTTP/2 client associated with a single ``remote`` host. Always uses HTTPS.
    @frozen public
    struct Client2:@unchecked Sendable
    {
        /// We must **never** modify the bootstrap after initialization!
        @usableFromInline
        let _bootstrap:ClientBootstrap

        /// The hostname of the remote service.
        public
        let remote:String

        private
        init(_bootstrap:ClientBootstrap, remote:String)
        {
            self._bootstrap = _bootstrap
            self.remote = remote
        }
    }
}
extension HTTP.Client2
{
    public
    init(threads:MultiThreadedEventLoopGroup, niossl:NIOSSLContext, remote:String)
    {
        let _bootstrap:ClientBootstrap = .init(group: threads)
            .connectTimeout(.seconds(3))
            .channelInitializer
        {
            (channel:any Channel) in

            do
            {
                let tls:NIOSSLClientHandler = try .init(context: niossl,
                    serverHostname: remote)

                return channel.pipeline.addHandler(tls)
                    .flatMap
                {
                    channel.configureHTTP2Pipeline(mode: .client,
                        connectionConfiguration: .init(),
                        streamConfiguration: .init())
                    {
                        //  With no owner, the stream is unsolicited and will drop any
                        //  responses it receives.
                        $0.pipeline.addHandler(StreamHandler.init(owner: nil))
                    }
                        .flatMap
                    {
                        (multiplexer:NIOHTTP2Handler.StreamMultiplexer) in

                        channel.pipeline.addHandler(InterfaceHandler.init(
                            multiplexer: multiplexer))
                    }
                }
            }
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }

        self.init(_bootstrap: _bootstrap, remote: remote)
    }
}
extension HTTP.Client2
{
    public
    func fetch(_ request:__owned HPACKHeaders) async throws -> Facet
    {
        try await self.connect { try await $0.fetch(request) }
    }
    public
    func fetch(_ request:__owned Request) async throws -> Facet
    {
        try await self.connect { try await $0.fetch(request) }
    }
}
extension HTTP.Client2:HTTP.Client
{
    /// Connect to the remote host over HTTPS and perform the given operation.
    @inlinable public
    func connect<T>(port:Int = 443, with body:(Connection) async throws -> T) async throws -> T
    {
        let channel:any Channel = try await self._bootstrap.connect(
            host: self.remote,
            port: port).get()

        defer
        {
            channel.close(promise: nil)
        }

        return try await body(Connection.init(channel: channel, remote: self.remote))
    }
}
