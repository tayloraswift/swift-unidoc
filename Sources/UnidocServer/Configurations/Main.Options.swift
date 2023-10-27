import HTTPServer

extension Main
{
    struct Options:Sendable
    {
        var authority:Authority
        var certificates:String
        var redirect:Bool
        /// Whether to enable GitHub integration if access keys are available.
        /// Defaults to false.
        var github:Bool
        var mongo:String
        /// This is the port that the server binds to. It is not necessarily
        /// the port that the server is accessed through.
        var port:Int?

        init()
        {
            self.authority = .localhost
            self.certificates = "TestCertificates"
            self.redirect = false
            self.github = false
            self.mongo = "unidoc-mongod"
            self.port = nil
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

                options.port = port

            case let unrecognized:
                throw Main.OptionsError.unrecognized(unrecognized)
            }
        }

        return options
    }
}
