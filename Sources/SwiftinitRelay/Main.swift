import NIOCore
import NIOPosix

@main
enum Main
{
    public static
    func main() async throws
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let bootstrap:ServerBootstrap = .init(group: executor)
            .serverChannelOption(ChannelOptions.socket(.init(SOL_SOCKET), SO_REUSEADDR),
                value: 1)
            .childChannelOption(ChannelOptions.socket(.init(SOL_SOCKET), SO_REUSEADDR),
                value: 1)
            .childChannelInitializer
        {
            (incoming:any Channel) in

            let incomingHandler:GlueHandler
            let outgoingHandler:NIOLoopBound<GlueHandler>

            (incomingHandler, outgoingHandler) = GlueHandler.bridge(on: incoming.eventLoop)

            let bootstrap:ClientBootstrap = .init(group: incoming.eventLoop)
                .connectTimeout(.seconds(3))
                .channelInitializer
            {
                $0.pipeline.addHandler(outgoingHandler.value)
            }

            let host:String = "example.com" // "93.184.216.34"

            let future:EventLoopFuture = incoming.pipeline.addHandler(incomingHandler)
                .and(bootstrap.connect(host: host, port: 443))
                .map
            {
                _ in print("Connected to \(host)")
            }

            //  Break reference cycle.
            future.whenFailure
            {
                _ in outgoingHandler.value.unlink()
            }

            return future
        }

        let channel:any Channel = try await bootstrap.bind(host: "::", port: 8001).get()

        print("Listening...")

        try await channel.closeFuture.get()
    }
}
