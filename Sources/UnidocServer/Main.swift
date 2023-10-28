import MongoDB
import NIOPosix

@main
enum Main
{
    public static
    func main() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let options:Options = try .parse()
        if  options.redirect
        {
            try await options.authority.type.redirect(
                from: ("::", options.port ?? 80),
                on: threads)
            return
        }

        let mongodb:Mongo.DriverBootstrap = MongoDB / [options.mongo] /?
        {
            $0.executors = .shared(threads)
            $0.appname = "Unidoc Server"
        }

        defer
        {
            try? threads.syncShutdownGracefully()
        }

        try await mongodb.withSessionPool
        {
            @Sendable (pool:Mongo.SessionPool) in

            let server:Server = try await .init(
                options: try .init(from: options),
                threads: threads,
                mongodb: pool)

            try await server.run()
        }
    }
}
