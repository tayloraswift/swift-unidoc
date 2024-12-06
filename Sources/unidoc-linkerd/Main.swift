import ArgumentParser
import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOSSL
import System_
import System_ArgumentParser
import UnidocCLI
import UnidocLinkerPlugin
import UnidocServer
import UnidocServerInsecure

struct Main
{
    @Option(
        name: [.customLong("host"), .customShort("h")],
        help: "The name of a host to bind the documentation server to")
    var host:String = "localhost"

    @Option(
        name: [.customLong("port"), .customShort("p")],
        help: "The number of a port to bind the documentation server to")
    var port:Int = 8080

    @OptionGroup
    var db:Unidoc.DatabaseOptions
    @OptionGroup
    var s3:Unidoc.BucketOptions
}

@main
extension Main:AsyncParsableCommand
{
    func run() async throws
    {
        NIOSingletons.groupLoopCountSuggestion = 2

        let clientIdentity:NIOSSLContext = try .clientDefault

        let options:Unidoc.ServerOptions = .init(assetCache: nil,
            builders: 0,
            bucket: self.s3.buckets,
            github: nil,
            access: .enforced,
            origin: .https(host: self.host, port: self.port),
            preview: true)

        let mongodb:Mongo.DriverBootstrap = MongoDB / [self.db.mongod] /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
            $0.appname = "unidoc-linkerd"

            $0.connectionTimeout = .milliseconds(5_000)
            $0.monitorInterval = .milliseconds(3_000)

            $0.topology = .replicated(set: self.db.rs)
        }

        await mongodb.withSessionPool(logger: .init(level: .error))
        {
            @Sendable (pool:Mongo.SessionPool) in

            await Unidoc.ConsoleLogger.run
            {
                let settings:Unidoc.DatabaseSettings = .init(access: options.access)

                let linker:Unidoc.LinkerPlugin = .init(bucket: options.bucket.graphs)
                let server:Unidoc.Server = .init(clientIdentity: clientIdentity,
                    coordinators: [],
                    plugins: [linker],
                    options: options,
                    logger: $0,
                    db: .init(settings: settings, sessions: pool, unidoc: "unidoc"))

                try await server.run(on: self.port)
            }
        }
    }
}
