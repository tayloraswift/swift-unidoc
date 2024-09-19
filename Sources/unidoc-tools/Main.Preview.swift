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
            name: [.customLong("mongo"), .customShort("m")],
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
            name: [.customLong("mirror"), .customShort("q")],
            help: "Run in mirror mode, disabling the documentation linker process")
        var mirror:Bool = false

        @Flag(
            name: [.customLong("https"), .customShort("e")],
            help: "Use https instead of http")
        var https:Bool = false

        init()
        {
        }
    }
}
extension Main.Preview
{
    private
    var serverSSL:NIOSSLContext
    {
        get throws
        {
            let privateKeyPath:FilePath = self.certificates / "privkey.pem"
            let privateKey:NIOSSLPrivateKey = try .init(file: "\(privateKeyPath)", format: .pem)

            let fullChainPath:FilePath = self.certificates / "fullchain.pem"
            let fullChain:[NIOSSLCertificate] = try NIOSSLCertificate.fromPEMFile(
                "\(fullChainPath)")

            var configuration:TLSConfiguration = .makeServerConfiguration(
                certificateChain: fullChain.map(NIOSSLCertificateSource.certificate(_:)),
                privateKey: .privateKey(privateKey))

                // configuration.applicationProtocols = ["h2", "http/1.1"]
                configuration.applicationProtocols = ["h2"]

            return try .init(configuration: configuration)
        }
    }

    private
    var clientSSL:NIOSSLContext
    {
        get throws
        {
            var configuration:TLSConfiguration = .makeClientConfiguration()
                configuration.applicationProtocols = ["h2"]
            return try .init(configuration: configuration)
        }
    }
}

extension Main.Preview:AsyncParsableCommand
{
    public
    static let configuration:CommandConfiguration = .init(commandName: "preview")

    func run() async throws
    {
        NIOSingletons.groupLoopCountSuggestion = 2

        var development:Unidoc.ServerOptions.Development = .init(replicaSet: self.replicaSet)
        let authority:any HTTP.ServerAuthority

        if  self.https
        {
            authority = HTTP.LocalhostSecure.init(context: try self.serverSSL)
            development.port = self.port ?? 8443
        }
        else
        {
            authority = HTTP.Localhost.init()
            development.port = self.port ?? 8080
        }

        let options:Unidoc.ServerOptions = .init(authority: authority,
            github: nil,
            mirror: self.mirror,
            bucket: .init(
                assets: development.bucket,
                graphs: development.bucket),
            mode: .development(.init(source: "Assets"), development))

        let mongodb:Mongo.DriverBootstrap = MongoDB / [self.mongod] /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
            $0.appname = "Unidoc Preview"

            $0.connectionTimeout = .milliseconds(5_000)
            $0.monitorInterval = .milliseconds(3_000)

            $0.topology = .replicated(set: options.replicaSet)
        }

        await mongodb.withSessionPool(logger: .init(level: .error))
        {
            @Sendable (pool:Mongo.SessionPool) in
            do
            {
                let policy:Unidoc.SecurityPolicy = .init(security: options.mode.security)
                {
                    $0.apiLimitInterval = .milliseconds(60_000)
                    $0.apiLimitPerReset = 10000
                }

                let linker:Unidoc.GraphLinker = .init(bucket: nil)
                let server:Unidoc.Server = .init(clientIdentity: try self.clientSSL,
                    plugins: [linker],
                    options: options,
                    builds: nil,
                    db: .init(sessions: pool, unidoc: "unidoc",  policy: policy))

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
