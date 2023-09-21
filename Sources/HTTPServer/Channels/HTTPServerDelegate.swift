import HTTP
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOSSL

public
protocol HTTPServerDelegate<Operation>:Sendable
{
    associatedtype Operation:HTTPServerOperation

    func submit(_ operation:Operation, promise:EventLoopPromise<ServerResponse>)
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
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
            .childChannelInitializer
        {
            (channel:any Channel) -> EventLoopFuture<Void> in

            let endpoint:ServerInterfaceHandler<Authority, Self> = .init(
                address: channel.remoteAddress,
                server: self)


            return  channel.pipeline.addHandler(NIOSSLServerHandler.init(
                context: authority.tls))
                    .flatMap
            {
                    channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true)
                    .flatMap
                {
                    channel.pipeline.addHandler(endpoint)
                }
            }
        }

        let channel:any Channel = try await bootstrap.bind(
            host: binding.address,
            port: binding.port).get()

        print("bound to:", binding.address, binding.port)

        try await channel.closeFuture.get()
    }
}
