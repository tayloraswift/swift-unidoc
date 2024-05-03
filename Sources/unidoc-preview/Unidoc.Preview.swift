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
        var mongo:Mongo.Host

        private
        init() throws
        {
            self.certificates = "Local/Server/Certificates"
            self.development = .init()
            self.mirror = false
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

            case "-m", "--mongo":
                self.mongo = .init(try arguments.next(for: "mongo"))

            case "-p", "--port":
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
        let privateKey:NIOSSLPrivateKey =
            try .init(file: "\(self.certificates)/privkey.pem", format: .pem)
        let fullChain:[NIOSSLCertificate] =
            try NIOSSLCertificate.fromPEMFile("\(self.certificates)/fullchain.pem")

        var configuration:TLSConfiguration = .makeServerConfiguration(
            certificateChain: fullChain.map(NIOSSLCertificateSource.certificate(_:)),
            privateKey: .privateKey(privateKey))

            // configuration.applicationProtocols = ["h2", "http/1.1"]
            configuration.applicationProtocols = ["h2"]

        let authority:Localhost = .init(tls: try .init(configuration: configuration))

        let assets:FilePath = "Assets"
        let github:GitHub.Integration?
        do
        {
            github = try .load(secrets: assets / "secrets", localhost: true)
        }
        catch let error
        {
            //  TODO: this is currently always disabled unless the user has gone through the
            //  trouble of creating a personal GitHub App.
            Log[.debug] = "GitHub integration disabled (\(error))"
            github = nil
        }

        return .init(authority: authority,
            github: github,
            mirror: self.mirror,
            bucket: .init(
                assets: self.development.bucket,
                graphs: self.development.bucket),
            mode: .development(.init(source: assets), self.development))
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
                let server:Unidoc.ServerLoop = try await .init(
                    context: context,
                    options: options,
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