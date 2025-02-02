import ArgumentParser
import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOSSL
import SystemIO
import System_ArgumentParser
import UnidocCLI
import UnidocLinkerPlugin
import UnidocServer
import UnidocServerInsecure

extension Unidoc
{
    struct PreviewCommand
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
            name: [.customLong("port"), .customShort("p")],
            help: "The number of a port to bind the documentation server to")
        var port:Int?

        @OptionGroup
        var db:DatabaseOptions

        @Flag(
            name: [.customLong("https"), .customShort("e")],
            help: "Use https instead of http")
        var https:Bool = false

        init() {}
    }
}
extension Unidoc.PreviewCommand:AsyncParsableCommand
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

        let mongodb:Mongo.DriverBootstrap = MongoDB / [self.db.mongod] /?
        {
            $0.executors = MultiThreadedEventLoopGroup.singleton
            $0.appname = "Unidoc Preview"

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
                {
                    $0.apiLimitInterval = .milliseconds(60_000)
                    $0.apiLimitPerReset = 10000
                }

                let linker:Unidoc.LinkerPlugin = .init(bucket: nil)
                let server:Unidoc.Server = .init(clientIdentity: clientIdentity,
                    coordinators: [],
                    plugins: [linker],
                    options: options,
                    logger: $0,
                    db: .init(settings: settings, sessions: pool, unidoc: "unidoc"))

                try await server.run(on: port,
                    with: serverIdentity.map(HTTP.ServerEncryptionLayer.local(_:)))
            }
        }
    }
}
