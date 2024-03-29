import ArgumentParsing
import Symbols
import Unidoc

extension Main
{
    struct Options:Sendable
    {
        var package:Symbol.Package?
        var cookie:String
        var host:String
        var port:Int

        var pretty:Bool
        var swift:String?
        var force:Unidoc.BuildLatest?
        var input:String?

        var tool:Tool

        private
        init()
        {
            self.package = nil
            self.cookie = ""
            self.host = "localhost"
            self.port = 8443

            self.pretty = false
            self.swift = nil
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
                options.host = "swiftinit.org"
                options.port = 443

                options.cookie = try arguments.next(for: option)

            case "--cookie", "-i":
                options.cookie = try arguments.next(for: option)

            case "--host", "-h":
                options.host = try arguments.next(for: option)

            case "--port", "-p":
                options.port = try arguments.next(for: option)

            case "--pretty", "-o":
                options.pretty = true

            case "--swift", "-s":
                options.swift = try arguments.next(for: option)

            case "--input", "-I":
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
