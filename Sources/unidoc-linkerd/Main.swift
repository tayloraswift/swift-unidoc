import ArgumentParser
import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOSSL
import System_
import System_ArgumentParser
import UnidocLinkerPlugin
import UnidocServer
import UnidocServerInsecure

struct Main
{
    @Option(
        name: [.customLong("certificates"), .customShort("c")],
        help: "A path to the certificates directory",
        completion: .directory)
    var certificates:FilePath.Directory = "Assets/certificates"

    @Option(
        name: [.customLong("mongod"), .customLong("mongo"), .customShort("m")],
        help: "The name of a host running mongod to connect to, and optionally, the port")
    var mongod:Mongo.Host = "localhost"

    @Option(
        name: [.customLong("replica-set"), .customShort("s")],
        help: "The name of a replica set to connect to")
    var replicaSet:String = "unidoc-rs"

    @Option(
        name: [.customLong("host"), .customShort("h")],
        help: "The name of a host to bind the documentation server to")
    var host:String = "localhost"

    @Option(
        name: [.customLong("port"), .customShort("p")],
        help: "The number of a port to bind the documentation server to")
    var port:Int = 8443

    @Option(
        name: [.customLong("s3-assets")],
        help: """
            The name of an S3 bucket in the us-east-1 region
            """)
    var s3Assets:String?

    @Option(
        name: [.customLong("s3")],
        help: """
            The name of an S3 bucket in the us-east-1 region
            """)
    var s3Bucket:String
}

@main
extension Main:AsyncParsableCommand
{
    func run() async throws
    {
        NIOSingletons.groupLoopCountSuggestion = 2

        let clientIdentity:NIOSSLContext = try .clientDefault
        let serverIdentity:NIOSSLContext = try .serverDefault(
            certificateDirectory: "\(self.certificates)")

        let options:Unidoc.ServerOptions = .init(assetCache: nil,
            builders: 0,
            bucket: .init(
                assets: .init(region: .us_east_1, name: self.s3Assets ?? self.s3Bucket),
                graphs: .init(region: .us_east_1, name: self.s3Bucket)),
            github: nil,
            access: .enforced,
            origin: .https(host: self.host, port: self.port),
            preview: true)

        let mongodb:Mongo.DriverBootstrap = MongoDB / [self.mongod] /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
            $0.appname = "unidoc-linkerd"

            $0.connectionTimeout = .milliseconds(5_000)
            $0.monitorInterval = .milliseconds(3_000)

            $0.topology = .replicated(set: self.replicaSet)
        }

        await mongodb.withSessionPool(logger: .init(level: .error))
        {
            @Sendable (pool:Mongo.SessionPool) in
            do
            {
                let settings:Unidoc.DatabaseSettings = .init(access: options.access)

                let linker:Unidoc.LinkerPlugin = .init(bucket: nil)
                let server:Unidoc.Server = .init(clientIdentity: clientIdentity,
                    coordinators: [],
                    plugins: [linker],
                    options: options,
                    db: .init(settings: settings, sessions: pool, unidoc: "unidoc"))

                try await server.run(on: self.port, with: serverIdentity)
            }
            catch let error
            {
                //  Temporary workaround for bypassing backtrace collection.
                Log[.error] = "(top-level) \(error)"
            }
        }
    }
}
