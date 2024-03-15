import GitHubAPI
import HTTPServer
import MongoDB
import NIOPosix
import NIOSSL
import S3
import System

struct Main
{
    var authority:any ServerAuthority.Type
    var certificates:String

    /// Options specific to development mode. These are ignored if the server is
    /// bound to an authority besides ``Localhost``.
    var development:Swiftinit.ServerOptions.Development

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

            case "-b", "--bucket":
                guard let bucket:String = arguments.next()
                else
                {
                    throw Main.OptionsError.invalidBucketName(nil)
                }

                self.development.bucket = .init(region: .us_east_1, name: bucket)

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

            case "-q", "--mirror":
                self.mirror = true

            case "-r", "--redirect":
                self.redirect = true

            case "-s", "--replica-set":
                guard let replicaSet:String = arguments.next()
                else
                {
                    throw Main.OptionsError.invalidReplicaSet
                }

                self.development.replicaSet = replicaSet

            case "-m", "--mongo":
                switch arguments.next()
                {
                case let host?:     self.mongo = .init(host)
                case nil:           throw Main.OptionsError.invalidMongoReplicaSetSeed
                }

            case "--enable-github":
                Log[.warning] = """
                This option is deprecated, GitHub integration is now always enabled.
                """

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

        let authority:any ServerAuthority = self.authority.init(
            tls: try .init(configuration: configuration))

        let assets:FilePath = "Assets"
        let github:GitHub.Integration?
        do
        {
            github = try .load(secrets: assets / "secrets")
        }
        catch let error
        {
            //  Temporary workaround for bypassing backtrace collection.
            Log[.debug] = "GitHub integration disabled (\(error))"
            github = nil
        }

        if  self.authority is Localhost.Type
        {
            return .init(authority: authority,
                github: github,
                mirror: self.mirror,
                bucket: self.development.bucket,
                mode: .development(.init(source: assets), self.development))
        }
        else
        {
            return .init(authority: authority,
                github: github,
                mirror: self.mirror,
                bucket: .init(region: .us_east_1, name: "symbolgraphs"),
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

            let context:Swiftinit.ServerPluginContext = .init(threads: threads,
                niossl: try .init(configuration: configuration))
            let options:Swiftinit.ServerOptions = try self.options()

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

                var plugins:[any Swiftinit.ServerPlugin] = []

                if  options.whitelists
                {
                    plugins.append(Swiftinit.PolicyPlugin.init())
                }

                nonmirror:
                if !options.mirror
                {
                    plugins.append(Swiftinit.LinkerPlugin.init(bucket: options.bucket))

                    guard
                    let github:GitHub.Integration = options.github
                    else
                    {
                        break nonmirror
                    }

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
