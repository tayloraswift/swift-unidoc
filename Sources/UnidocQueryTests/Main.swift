import MongoDB
import NIOPosix
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
    {
        let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let mongodb:Mongo.DriverBootstrap = MongoDB / ["unidoc-mongod"] /?
        {
            $0.executors = .shared(executors)
            $0.appname = "example app"
        }

        defer
        {
            try? executors.syncShutdownGracefully()
        }

        await mongodb.run(tests,
            DatabaseQueries.init())
    }
}
