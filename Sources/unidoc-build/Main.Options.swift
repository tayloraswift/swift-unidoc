import ArgumentParsing
import Symbols
import Unidoc

extension Unidoc
{
    struct Options:Sendable
    {
        var package:Symbol.Package?
        var cookie:String
        var host:String
        var port:Int

        var pretty:Bool
        var swift:String?
        var swiftSDK:SSGC.AppleSDK?
        var force:Unidoc.VersionSeries?
        var input:String?

        private
        init()
        {
            self.package = nil
            self.cookie = ""
            self.host = "localhost"
            self.port = 8443

            self.pretty = false
            self.swift = nil
            self.swiftSDK = nil
            self.force = nil
            self.input = nil
        }
    }
}
extension Unidoc.Options
{
    static
    func parse(arguments:consuming CommandLine.Arguments) throws -> Self
    {
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

            case "--swift-sdk", "-k":
                options.swiftSDK = try arguments.next(for: option)

            case "--input", "-I":
                options.input = try arguments.next(for: option)

            case "--force", "-f":
                options.force = .release

            case "--force-prerelease", "-e":
                options.force = .prerelease

            // case "--builder", "-b":
            //     options.tool = .builder

            // case "--upgrade", "-a":
            //     options.tool = .upgrade

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
extension Unidoc.Options
{
    func toolchain() throws -> SSGC.Toolchain
    {
        try .detect(
            swiftPath: self.swift ?? "swift",
            swiftSDK: self.swiftSDK,
            pretty: self.pretty)
    }

    func client() throws -> Unidoc.Client
    {
        try .init(host: self.host, port: self.port, cookie: self.cookie)
    }
}
