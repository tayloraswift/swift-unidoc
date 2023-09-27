import HTTPServer

extension Server
{
    struct Options
    {
        var authority:Authority
        var certificates:String
        var redirect:Bool
        var mongo:String
        /// This is the port that the server binds to. It is not necessarily
        /// the port that the server is accessed through.
        var port:Int

        init()
        {
            self.authority = .localhost
            self.certificates = "TestCertificates"
            self.redirect = false
            self.mongo = "unidoc-mongod"
            self.port = 8443
        }
    }
}
extension Server.Options
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
                    throw Server.OptionsError.invalidAuthority(nil)
                }
                guard let authority:Authority = .init(rawValue: authority)
                else
                {
                    throw Server.OptionsError.invalidAuthority(authority)
                }

                options.authority = authority

            case "-c", "--certificates":
                guard let certificates:String = arguments.next()
                else
                {
                    throw Server.OptionsError.invalidCertificateDirectory
                }

                options.certificates = certificates

            case "-r", "--redirect":
                options.redirect = true

            case "-m", "--mongo":
                switch arguments.next()
                {
                case let host?:     options.mongo = host
                case nil:           throw Server.OptionsError.invalidMongoReplicaSetSeed
                }

            case "-p", "--port":
                guard let port:String = arguments.next()
                else
                {
                    throw Server.OptionsError.invalidPort(nil)
                }
                guard let port:Int = .init(port)
                else
                {
                    throw Server.OptionsError.invalidPort(port)
                }

                options.port = port

            case let unrecognized:
                throw Server.OptionsError.unrecognized(unrecognized)
            }
        }

        //  Sanity checks.
        if  options.port == 80 || options.port == 443,
            case .localhost = options.authority
        {
            print("""
                warning: server is running on port \(options.port) but is using hostname \
                localhost!
                """)
        }

        return options
    }
}
