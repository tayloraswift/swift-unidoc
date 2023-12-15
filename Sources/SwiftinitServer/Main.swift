import HTTPServer
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
            try await options.authority.type.redirect(from: ("::", 80), on: threads)
            return
        }

        let mongodb:Mongo.DriverBootstrap = MongoDB / [options.mongo] /?
        {
            $0.executors = .shared(threads)
            $0.appname = "Unidoc Server"

            $0.connectionTimeout = .seconds(5)
            $0.monitorInterval = .seconds(5)
        }

        defer
        {
            try? threads.syncShutdownGracefully()
        }

        await mongodb.withSessionPool
        {
            @Sendable (pool:Mongo.SessionPool) in

            do
            {
                let server:Swiftinit.ServerLoop = try await .init(
                    options: try .init(from: options),
                    threads: threads,
                    mongodb: pool)

                try await server.run()
            }
            catch let error
            {
                //  Temporary workaround for bypassing backtrace collection.
                Log[.error] = "(top-level) \(error)"
            }
        }
    }
}
