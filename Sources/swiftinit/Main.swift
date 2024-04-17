import ArgumentParsing
import GitHubAPI
import HTTPServer
import MongoDB
import NIOPosix
import NIOSSL
import S3
import System
import UnidocServer

struct Main
{
    var authority:any ServerAuthority.Type
    var certificates:String

    /// Options specific to development mode. These are ignored if the server is
    /// bound to an authority besides ``Localhost``.
    var development:Unidoc.ServerOptions.Development

    var redirect:Bool
    var mirror:Bool
    var mongo:Mongo.Host

    private
    init() throws
    {
        self.authority = Localhost.self
        self.certificates = "Local/Server/Certificates"
        self.development = .init()
        self.redirect = false
        self.mirror = false
        self.mongo = "unidoc-mongod"
    }
}
extension Main
{
    private mutating
    func parse() throws
    {
        var arguments:CommandLine.Arguments = .init()

        while let argument:String = arguments.next()
        {
            switch argument
            {
            case "-a", "--authority":
                switch try arguments.next(for: "authority")
                {
                case "production":  self.authority = Swiftinit.Prod.self
                case "testing":     self.authority = Swiftinit.Test.self
                case "localhost":   self.authority = Localhost.self
                case let invalid:
                    throw CommandLine.ArgumentError.invalid("authority", value: invalid)
                }

            case "-b", "--bucket":
                self.development.bucket = .init(
                    region: .us_east_1,
                    name: try arguments.next(for: "bucket"))

            case "-c", "--certificates":
                self.certificates = try arguments.next(for: "certificates")

            case "--enable-cloudfront":
                self.development.cloudfront = true

            case "--enable-github":
                self.development.runTelescope = true
                self.development.runMonitor = true

            case "--enable-whitelists":
                self.development.runPolicy = true

            case "-q", "--mirror":
                self.mirror = true

            case "-r", "--redirect":
                self.redirect = true

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
extension Main
{
    static
    func main() async throws
    {
        var main:Self = try .init()
        try main.parse()
        try await main.launch()
    }
}
extension Main
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

        let authority:any ServerAuthority = self.authority.init(
            tls: try .init(configuration: configuration))
        let localhost:Bool = self.authority is Localhost.Type

        let assets:FilePath = "Assets"
        let github:GitHub.Integration?
        do
        {
            github = try .load(secrets: assets / "secrets", localhost: localhost)
        }
        catch let error
        {
            //  Temporary workaround for bypassing backtrace collection.
            Log[.debug] = "GitHub integration disabled (\(error))"
            github = nil
        }

        if  localhost
        {
            return .init(authority: authority,
                github: github,
                mirror: self.mirror,
                bucket: .init(
                    assets: self.development.bucket,
                    graphs: self.development.bucket),
                mode: .development(.init(source: assets), self.development))
        }
        else
        {
            return .init(authority: authority,
                github: github,
                mirror: self.mirror,
                bucket: .init(
                    assets: .init(region: .us_east_1, name: "swiftinit"),
                    graphs: .init(region: .us_east_1, name: "symbolgraphs")),
                mode: .production)
        }
    }

    private consuming
    func launch() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        defer
        {
            try? threads.syncShutdownGracefully()
        }

        if  self.redirect
        {
            try await self.authority.redirect(from: ("::", 80), on: threads)
        }
        else
        {
            let mongod:Mongo.Host = self.mongo

            var configuration:TLSConfiguration = .makeClientConfiguration()
                configuration.applicationProtocols = ["h2"]

            let context:Unidoc.ServerPluginContext = .init(threads: threads,
                niossl: try .init(configuration: configuration))
            let options:Unidoc.ServerOptions = try self.options()

            let mongodb:Mongo.DriverBootstrap = MongoDB / [mongod] /?
            {
                $0.executors = .shared(threads)
                $0.appname = "Unidoc Server"

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
}
