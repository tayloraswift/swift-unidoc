import NIOCore
import NIOPosix

@main
enum Main
{
    public static
    func main() async throws
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 1)
        let bootstrap:ServerBootstrap = .init(group: executor)
            .serverChannelOption(ChannelOptions.socket(.init(SOL_SOCKET), SO_REUSEADDR),
                value: 1)
            .childChannelOption(ChannelOptions.socket(.init(SOL_SOCKET), SO_REUSEADDR),
                value: 1)
            .childChannelInitializer
        {
            (incoming:any Channel) in

            let bridge:(GlueHandler, GlueHandler) = GlueHandler.bridge()

            let bootstrap:ClientBootstrap = .init(group: executor)
                .connectTimeout(.seconds(3))
                .channelInitializer
            {
                $0.pipeline.addHandler(bridge.1)
            }

            let forward:EventLoopFuture<any Channel> = bootstrap.connect(
                host: "google.com",
                port: 443)

            return incoming.pipeline.addHandler(bridge.0)
                .and(forward)
                .map
            {
                _ in
                print("Connected to google.com")
            }
        }

        let channel:any Channel = try await bootstrap.bind(host: "127.0.0.1", port: 8001).get()

        print("Listening...")

        try await channel.closeFuture.get()
    }
}
