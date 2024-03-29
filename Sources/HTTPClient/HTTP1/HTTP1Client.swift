import NIOCore
import NIOPosix
import NIOSSL

@frozen public
struct HTTP1Client
{
    @usableFromInline internal
    let bootstrap:ClientBootstrap

    /// The hostname of the remote service.
    public
    let remote:String

    private
    init(bootstrap:ClientBootstrap, remote:String)
    {
        self.bootstrap = bootstrap
        self.remote = remote
    }
}
extension HTTP1Client:Identifiable
{
    /// Returns the ``remote`` hostname.
    @inlinable public
    var id:String { self.remote }
}
extension HTTP1Client
{
    public
    init(threads:MultiThreadedEventLoopGroup, niossl:NIOSSLContext, remote:String)
    {
        let bootstrap:ClientBootstrap = .init(group: threads)
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
                    channel.pipeline.addHTTPClientHandlers()
                        .flatMap
                    {
                        channel.pipeline.addHandler(InterfaceHandler.init())
                    }
                }
            }
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }

        self.init(bootstrap: bootstrap, remote: remote)
    }
}
extension HTTP1Client
{
    /// Connect to the remote host over HTTPS and perform the given operation.
    @inlinable public
    func connect<T>(port:Int = 443, with body:(Connection) async throws -> T) async throws -> T
    {
        let channel:any Channel = try await self.bootstrap.connect(
            host: self.remote,
            port: port).get()

        defer
        {
            channel.close(promise: nil)
        }

        return try await body(Connection.init(channel: channel))
    }
}
