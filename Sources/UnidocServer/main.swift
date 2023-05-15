import MongoDB
import NIOCore
import NIOPosix

@main public
enum Main
{
    public static
    func main() async throws
    {
        let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        let bootstrap:Mongo.DriverBootstrap = MongoDB / ["unidoc-mongod"] /?
        {
            $0.executors = .shared(executors)
            $0.appname = "example app"
        }
        let configuration:Mongo.ReplicaSetConfiguration = try await bootstrap.withSessionPool
        {
            try await $0.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin)
        }

        print(configuration)

        try await executors.shutdownGracefully()
    }
}
