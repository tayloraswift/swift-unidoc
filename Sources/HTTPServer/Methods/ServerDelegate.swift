import NIOCore
import NIOPosix
import NIOHTTP1
import NIOSSL

public
protocol ServerDelegate<GetRequest, PostRequest>:Sendable
{
    associatedtype GetRequest:ServerDelegateGetRequest = Never
    associatedtype PostRequest:ServerDelegatePostRequest = Never

    func serve(get:GetRequest)
    func serve(post:PostRequest)
}
extension ServerDelegate where GetRequest == Never
{
    @inlinable public
    func serve(get _:Never)
    {
    }
}
extension ServerDelegate where PostRequest == Never
{
    @inlinable public
    func serve(post _:Never)
    {
    }
}
extension ServerDelegate
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

            let endpoint:ServerInterfaceHandler<Authority, Self> = .init(delegate: self,
                address: channel.remoteAddress)

            guard let tls:NIOSSLContext = authority.tls as? NIOSSLContext
            else
            {
                return channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true)
                    .flatMap
                {
                    channel.pipeline.addHandler(endpoint)
                }
            }
            return  channel.pipeline.addHandler(NIOSSLServerHandler.init(context: tls))
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
