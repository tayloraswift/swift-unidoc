import Symbols

extension Main
{
    enum Tool
    {
        case build
        case uplink
        case uplinkMultiple
    }
}
extension Main
{
    struct Options:Sendable
    {
        var package:Symbol.Package
        var cookie:String
        var remote:String
        var port:Int

        var pretty:Bool
        var force:Bool
        var input:String?

        var tool:Tool

        private
        init(package:Symbol.Package)
        {
            self.package = package
            self.cookie = ""
            self.remote = "unidoc-local"
            self.port = 8443

            self.pretty = false
            self.force = false
            self.input = nil

            self.tool = .build
        }
    }
}
extension Main.Options
{
    static
    func parse() throws -> Self
    {
        var arguments:ArraySlice<String> = CommandLine.arguments[1...]

        guard
        let package:String = arguments.popFirst()
        else
        {
            fatalError("Usage: \(CommandLine.arguments[0]) <package>")
        }

        var options:Self = .init(package: .init(package))

        while let option:String = arguments.popFirst()
        {
            switch option
            {
            case "--cookie", "-i":
                guard
                let cookie:String = arguments.popFirst()
                else
                {
                    fatalError("Expected cookie after '\(option)'")
                }

                options.cookie = cookie

            case "--remote", "-h":
                guard
                let remote:String = arguments.popFirst()
                else
                {
                    fatalError("Expected remote hostname after '\(option)'")
                }

                options.remote = remote

            case "--port", "-p":
                guard
                let port:String = arguments.popFirst(),
                let port:Int = .init(port)
                else
                {
                    fatalError("Expected port number after '\(option)'")
                }

                options.port = port

            case "--swiftinit", "-S":
                options.remote = "swiftinit.org"
                options.port = 443

            case "--pretty", "-P":
                options.pretty = true

            case "--input", "-r":
                guard
                let input:String = arguments.popFirst()
                else
                {
                    fatalError("Expected project path after '\(option)'")
                }

                options.input = input

            case "--force", "-f":
                options.force = true

            case "--uplink-only", "-u":
                options.tool = .uplink

            case "--uplink-multi":
                options.tool = .uplinkMultiple

            case let option:
                fatalError("Unknown option '\(option)'")
            }
        }

        return options
    }
}
