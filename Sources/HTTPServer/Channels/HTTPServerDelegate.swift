import HTTP
import IP
import NIOCore
import NIOPosix
import NIOHTTP2
import NIOSSL

public
protocol HTTPServerDelegate<Operation>:Sendable
{
    associatedtype Operation:HTTPServerOperation

    func submit(_ operation:Operation, promise:EventLoopPromise<ServerResponse>)

    var meter:HTTP.ServerMeter { get }
}
extension HTTPServerDelegate
{
    public
    func serve<Authority>(
        from binding:(address:String, port:Int),
        as authority:Authority,
        on threads:MultiThreadedEventLoopGroup) async throws
        where Authority:ServerAuthority
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .serverChannelOption(ChannelOptions.autoRead, value: false)
            .serverChannelInitializer
        {
            $0.pipeline.addHandler(HTTP.ServerConnectionHandler.init())
        }
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelInitializer
        {
            (channel:any Channel) -> EventLoopFuture<Void> in

            return channel.pipeline.addHandler(NIOSSLServerHandler.init(context: authority.tls))
                .flatMap
            {
                channel.configureCommonHTTPServerPipeline
                {
                    $0.pipeline.addHandler(HTTP.ServerInterfaceHandler<Authority, Self>.init(
                        address: channel.remoteAddress,
                        server: self))
                }
            }
        }

        let channel:any Channel = try await bootstrap.bind(
            host: binding.address,
            port: binding.port).get()

        Log[.debug] = "bound to \(binding.address):\(binding.port)"

        channel.read()

        try await channel.closeFuture.get()
    }
}
