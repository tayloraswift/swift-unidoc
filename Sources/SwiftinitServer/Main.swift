import GitHubAPI
import HTTPServer
import MongoDB
import NIOPosix
import NIOSSL
import System

struct Main
{
    var authority:any ServerAuthority.Type
    var certificates:String

    /// Options specific to development mode. These are ignored if the server is
    /// bound to an authority besides ``Localhost``.
    var development:Swiftinit.ServerOptions.Development

    var redirect:Bool
    /// Whether to enable GitHub integration if access keys are available.
    /// Defaults to false.
    var github:Bool
    var mongo:String

    private
    init() throws
    {
        self.authority = Localhost.self
        self.certificates = "Local/Server/Certificates"
        self.development = .init()
        self.redirect = false
        self.github = false
        self.mongo = "unidoc-mongod"
    }
}
extension Main
{
    private mutating
    func parse() throws
    {
        var arguments:IndexingIterator<[String]> = CommandLine.arguments.makeIterator()

        //  Consume name of the executable itself.
        let _:String? = arguments.next()

        while let argument:String = arguments.next()
        {
            switch argument
            {
            case "-a", "--authority":
                guard let authority:String = arguments.next()
                else
                {
                    throw OptionsError.invalidAuthority(nil)
                }
                switch authority
                {
                case "production":  self.authority = Swiftinit.Prod.self
                case "testing":     self.authority = Swiftinit.Test.self
                case "localhost":   self.authority = Localhost.self
                case let invalid:   throw OptionsError.invalidAuthority(invalid)
                }

            case "-c", "--certificates":
                guard let certificates:String = arguments.next()
                else
                {
                    throw Main.OptionsError.invalidCertificateDirectory
                }

                self.certificates = certificates

            case "--enable-cloudfront":
                self.development.cloudfront = true

            case "--enable-whitelists":
                self.development.whitelists = true

            case "-r", "--redirect":
                self.redirect = true

            case "-m", "--mongo":
                switch arguments.next()
                {
                case let host?:     self.mongo = host
                case nil:           throw Main.OptionsError.invalidMongoReplicaSetSeed
                }

            case "--enable-github":
                self.github = true

            case "-p", "--port":
                guard let port:String = arguments.next()
                else
                {
                    throw Main.OptionsError.invalidPort(nil)
                }
                guard let port:Int = .init(port)
                else
                {
                    throw Main.OptionsError.invalidPort(port)
                }

                self.development.port = port

            case let unrecognized:
                throw Main.OptionsError.unrecognized(unrecognized)
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
    func options() throws -> Swiftinit.ServerOptions
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

        var options:Swiftinit.ServerOptions = .init(authority: self.authority.init(
            tls: try .init(configuration: configuration)))

        let assets:FilePath = "Assets"
        if  self.github
        {
            options.github = try .load(secrets: assets / "secrets")
        }
        if  self.authority is Localhost.Type
        {
            options.mode = .development(.init(source: assets), self.development)
        }

        return options
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
            let mongodb:Mongo.DriverBootstrap = MongoDB / [self.mongo] /?
            {
                $0.executors = .shared(threads)
                $0.appname = "Unidoc Server"

                $0.connectionTimeout = .seconds(5)
                $0.monitorInterval = .seconds(5)
            }

            var configuration:TLSConfiguration = .makeClientConfiguration()
                configuration.applicationProtocols = ["h2"]

            let context:Swiftinit.ServerPluginContext = .init(threads: threads,
                niossl: try .init(configuration: configuration))
            let options:Swiftinit.ServerOptions = try self.options()

            await mongodb.withSessionPool
            {
                @Sendable (pool:Mongo.SessionPool) in

                var plugins:[any Swiftinit.ServerPlugin] =
                [
                    Swiftinit.LinkerPlugin.init(),
                ]

                if  options.whitelists
                {
                    plugins.append(Swiftinit.PolicyPlugin.init())
                }
                if  let github:GitHub.Integration = options.github
                {
                    plugins.append(GitHub.CrawlerPlugin<GitHub.RepoTelescope>.init(
                        api: github.api,
                        id: "telescope"))
                    plugins.append(GitHub.CrawlerPlugin<GitHub.RepoMonitor>.init(
                        api: github.api,
                        id: "monitor"))
                }

                do
                {
                    let server:Swiftinit.ServerLoop = try await .init(
                        plugins: plugins,
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
