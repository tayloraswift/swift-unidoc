import HTTPServer

extension Main
{
    struct Options:Sendable
    {
        var authority:Authority
        var certificates:String

        /// Options specific to development mode. These are ignored if the server is
        /// bound to an authority besides ``Localhost``.
        var development:Server.Options.Development

        var redirect:Bool
        /// Whether to enable GitHub integration if access keys are available.
        /// Defaults to false.
        var github:Bool
        var mongo:String

        init()
        {
            self.authority = .localhost
            self.certificates = "Local/Server/Certificates"
            self.development = .init()
            self.redirect = false
            self.github = false
            self.mongo = "unidoc-mongod"
        }
    }
}
extension Main.Options
{
    static
    func parse() throws -> Self
    {
        var arguments:IndexingIterator<[String]> = CommandLine.arguments.makeIterator()
        var options:Self = .init()

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
                    throw Main.OptionsError.invalidAuthority(nil)
                }
                guard let authority:Authority = .init(rawValue: authority)
                else
                {
                    throw Main.OptionsError.invalidAuthority(authority)
                }

                options.authority = authority

            case "-c", "--certificates":
                guard let certificates:String = arguments.next()
                else
                {
                    throw Main.OptionsError.invalidCertificateDirectory
                }

                options.certificates = certificates

            case "--enable-cloudfront":
                options.development.cloudfront = true

            case "--enable-whitelists":
                options.development.whitelists = true

            case "-r", "--redirect":
                options.redirect = true

            case "-m", "--mongo":
                switch arguments.next()
                {
                case let host?:     options.mongo = host
                case nil:           throw Main.OptionsError.invalidMongoReplicaSetSeed
                }

            case "--enable-github":
                options.github = true

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

                options.development.port = port

            case let unrecognized:
                throw Main.OptionsError.unrecognized(unrecognized)
            }
        }

        return options
    }
}
