import ArgumentParsing
import Symbols
import Unidoc

extension Main
{
    struct Options:Sendable
    {
        var package:Symbol.Package?
        var cookie:String
        var remote:String
        var port:Int

        var pretty:Bool
        var force:Unidoc.BuildLatest?
        var input:String?

        var tool:Tool

        private
        init()
        {
            self.package = nil
            self.cookie = ""
            self.remote = "localhost"
            self.port = 8443

            self.pretty = false
            self.force = nil
            self.input = nil

            self.tool = .latest
        }
    }
}

extension Main.Options
{
    static
    func parse() throws -> Self
    {
        var arguments:CommandLine.Arguments = .init()
        var options:Self = .init()

        while let option:String = arguments.next()
        {
            switch option
            {
            case "--swiftinit", "-S":
                options.remote = "swiftinit.org"
                options.port = 443

                options.cookie = try arguments.next(for: option)

            case "--cookie", "-i":
                options.cookie = try arguments.next(for: option)

            case "--remote", "-h":
                options.remote = try arguments.next(for: option)

            case "--port", "-p":
                options.port = try arguments.next(for: option)

            case "--pretty", "-P":
                options.pretty = true

            case "--input", "-r":
                options.input = try arguments.next(for: option)

            case "--force", "-f":
                options.force = .release

            case "--force-prerelease", "-e":
                options.force = .prerelease

            case "--upgrade":
                options.tool = .upgrade

            case let option:
                if  case nil = options.package
                {
                    options.package = .init(option)
                }
                else
                {
                    throw CommandLine.ArgumentError.unknown(option)
                }
            }
        }

        return options
    }
}
