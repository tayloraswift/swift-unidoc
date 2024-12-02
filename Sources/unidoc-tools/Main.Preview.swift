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

extension Main
{
    struct Preview
    {
        @Option(
            name: [.customLong("certificates"), .customShort("c")],
            help: "A path to the certificates directory",
            completion: .directory)
        var certificates:FilePath.Directory = "Assets/certificates"

        @Option(
            name: [.customLong("assets"), .customShort("a")],
            help: "A path to the assets directory",
            completion: .directory)
        var assets:FilePath.Directory = "Assets"

        @Option(
            name: [.customLong("mongod"), .customLong("mongo"), .customShort("m")],
            help: "The name of a host running mongod to connect to, and optionally, the port")
        var mongod:Mongo.Host = "localhost"

        @Option(
            name: [.customLong("replica-set"), .customShort("s")],
            help: "The name of a replica set to connect to")
        var replicaSet:String = "unidoc-rs"

        @Option(
            name: [.customLong("port"), .customShort("p")],
            help: "The number of a port to bind the documentation server to")
        var port:Int?

        @Flag(
            name: [.customLong("https"), .customShort("e")],
            help: "Use https instead of http")
        var https:Bool = false

        init() {}
    }
}
extension Main.Preview:AsyncParsableCommand
{
    public
    static let configuration:CommandConfiguration = .init(commandName: "preview")

    func run() async throws
    {
        NIOSingletons.groupLoopCountSuggestion = 2

        let clientIdentity:NIOSSLContext = try .clientDefault
        let serverIdentity:NIOSSLContext?
        let port:Int
        let origin:HTTP.ServerOrigin

        if  self.https
        {
            serverIdentity = try .serverDefault(certificateDirectory: "\(self.certificates)")
            port = self.port ?? 8443
            origin = .https(host: "localhost", port: port)
        }
        else
        {
            serverIdentity = nil
            port = self.port ?? 8080
            origin = .http(host: "localhost", port: port)
        }

        let options:Unidoc.ServerOptions = .init(
            assetCache: .init(source: self.assets.path),
            builders: 0,
            bucket: .init(assets: nil, graphs: nil),
            github: nil,
            access: .ignored,
            origin: origin,
            preview: true)

        let mongodb:Mongo.DriverBootstrap = MongoDB / [self.mongod] /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
            $0.appname = "Unidoc Preview"

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
                {
                    $0.apiLimitInterval = .milliseconds(60_000)
                    $0.apiLimitPerReset = 10000
                }

                let linker:Unidoc.LinkerPlugin = .init(bucket: nil)
                let server:Unidoc.Server = .init(clientIdentity: clientIdentity,
                    coordinators: [],
                    plugins: [linker],
                    options: options,
                    db: .init(settings: settings, sessions: pool, unidoc: "unidoc"))

                try await server.run(on: port, with: serverIdentity)
            }
            catch let error
            {
                //  Temporary workaround for bypassing backtrace collection.
                Log[.error] = "(top-level) \(error)"
            }
        }
    }
}
