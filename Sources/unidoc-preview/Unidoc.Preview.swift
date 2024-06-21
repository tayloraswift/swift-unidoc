import ArgumentParsing
import GitHubAPI
import HTTPServer
import MongoDB
import NIOPosix
import NIOSSL
import System
import UnidocServer

extension Unidoc
{
    struct Preview
    {
        var certificates:String

        var development:Unidoc.ServerOptions.Development
        var mirror:Bool
        var https:Bool
        var mongo:Mongo.Host

        private
        init() throws
        {
            self.certificates = "Assets/certificates"
            self.development = .init()
            self.mirror = false
            self.https = true
            self.mongo = "unidoc-mongod"
        }
    }
}
extension Unidoc.Preview
{
    private mutating
    func parse() throws
    {
        var arguments:CommandLine.Arguments = .init()

        while let argument:String = arguments.next()
        {
            switch argument
            {
            case "-c", "--certificates":
                self.certificates = try arguments.next(for: "certificates")

            case "-q", "--mirror":
                self.mirror = true

            case "-s", "--replica-set":
                self.development.replicaSet = try arguments.next(for: "replica-set")

            case "--http":
                self.https = false
                self.development.port = 8080

            case "-m", "--mongo":
                self.mongo = .init(try arguments.next(for: "mongo"))

            case "-p", "--port":
                self.https = true
                self.development.port = try arguments.next(for: "port")

            case let option:
                throw CommandLine.ArgumentError.unknown(option)
            }
        }
    }
}

@main
extension Unidoc.Preview
{
    static
    func main() async throws
    {
        var main:Self = try .init()
        try main.parse()
        try await main.launch()
    }
}
extension Unidoc.Preview
{
    private consuming
    func options() throws -> Unidoc.ServerOptions
    {
        let authority:any HTTP.ServerAuthority
        if  self.https
        {
            let privateKey:NIOSSLPrivateKey =
                try .init(file: "\(self.certificates)/privkey.pem", format: .pem)
            let fullChain:[NIOSSLCertificate] =
                try NIOSSLCertificate.fromPEMFile("\(self.certificates)/fullchain.pem")

            var configuration:TLSConfiguration = .makeServerConfiguration(
                certificateChain: fullChain.map(NIOSSLCertificateSource.certificate(_:)),
                privateKey: .privateKey(privateKey))

                // configuration.applicationProtocols = ["h2", "http/1.1"]
                configuration.applicationProtocols = ["h2"]

            authority = HTTP.LocalhostSecure.init(
                context: try .init(configuration: configuration))
        }
        else
        {
            authority = HTTP.Localhost.init()
        }

        return .init(authority: authority,
            github: nil,
            mirror: self.mirror,
            bucket: .init(
                assets: self.development.bucket,
                graphs: self.development.bucket),
            mode: .development(.init(source: "Assets"), self.development))
    }

    private consuming
    func launch() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        defer
        {
            try? threads.syncShutdownGracefully()
        }

        let mongod:Mongo.Host = self.mongo

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        let context:Unidoc.ServerPluginContext = .init(threads: threads,
            niossl: try .init(configuration: configuration))
        let options:Unidoc.ServerOptions = try self.options()

        let mongodb:Mongo.DriverBootstrap = MongoDB / [mongod] /?
        {
            $0.executors = .shared(threads)
            $0.appname = "Unidoc Preview"

            $0.connectionTimeout = .seconds(5)
            $0.monitorInterval = .seconds(3)

            $0.topology = .replicated(set: options.replicaSet)
        }

        await mongodb.withSessionPool(logger: .init(level: .error))
        {
            @Sendable (pool:Mongo.SessionPool) in
            do
            {
                let database:Unidoc.Database = .init(sessions: pool,
                    unidoc: await .setup(as: "unidoc", in: pool))
                {
                    $0.apiLimitInterval = .seconds(60)
                    $0.apiLimitPerReset = 10000
                }

                try await Unidoc.GraphStateLoop.run(watching: database)
                {
                    let linker:Unidoc.GraphLinkerPlugin = .init(bucket: nil)
                    let server:Unidoc.Server = .init(
                        plugins: [linker],
                        context: context,
                        options: options,
                        graphState: $0,
                        db: database)

                    try await server.run()
                }
            }
            catch let error
            {
                //  Temporary workaround for bypassing backtrace collection.
                Log[.error] = "(top-level) \(error)"
            }
        }
    }
}
