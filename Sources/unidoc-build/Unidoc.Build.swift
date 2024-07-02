import ArgumentParsing
import HTTP
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import System

extension Unidoc
{
    struct Build:Sendable
    {
        var project:Symbol.Package?
        var host:String
        var port:Int

        var pretty:Bool
        /// Use this option to build a local book project. Has no effect on server-tracked
        /// documentation builds.
        var book:Bool

        var executablePath:String?
        var swiftRuntime:String?
        var swiftPath:String?
        var swiftSDK:SSGC.AppleSDK?
        var input:String?

        private
        init()
        {
            self.project = nil
            self.host = "localhost"
            self.port = 8080

            self.pretty = false
            self.book = false

            self.executablePath = nil
            self.swiftRuntime = nil
            self.swiftPath = nil
            self.swiftSDK = nil
            self.input = nil
        }
    }
}

@MainActor @main
extension Unidoc.Build
{
    static
    func main() async
    {
        var arguments:CommandLine.Arguments = .init()
        guard
        let command:String = arguments.next()
        else
        {
            print("No command specified")
            SystemProcess.exit(with: 1)
        }

        if  command == "compile"
        {
            SystemProcess.exit(with: SSGC.main(arguments: arguments))
        }

        do
        {
            let build:Self = try .parse(arguments: arguments)
            try await build.local()
        }
        catch let error
        {
            print("Error: \(error)")
            SystemProcess.exit(with: 255)
        }
    }
}
extension Unidoc.Build
{
    private static
    func parse(arguments:consuming CommandLine.Arguments) throws -> Self
    {
        var options:Self = .init()

        while let option:String = arguments.next()
        {
            switch option
            {
            case "--host", "-h":
                options.host = try arguments.next(for: option)

            case "--port", "-p":
                options.port = try arguments.next(for: option)

            case "--pretty", "-o":
                options.pretty = true

            case "--book", "-b":
                options.book = true

            case "--swift-runtime", "-r":
                options.swiftRuntime = try arguments.next(for: option)

            case "--swift", "-s":
                options.swiftPath = try arguments.next(for: option)

            case "--swift-sdk", "-k":
                options.swiftSDK = try arguments.next(for: option)

            case "--input", "-I":
                options.input = try arguments.next(for: option)

            case "local":
                print("Warning: the 'local' subcommand is deprecated and no longer necessary.")

            case let option:
                if  case nil = options.project
                {
                    options.project = .init(option)
                }
                else
                {
                    throw CommandLine.ArgumentError.unknown(option)
                }
            }
        }

        //  On macOS, `/proc/self/exe` is not available, so we must fall back to using the
        //  path supplied by `argv[0]`.
        //
        //  FIXME: according to Alastair Houghton, we should be using `_NSGetExecutablePath`
        //  https://swift-open-source.slack.com/archives/C5FAE2LL9/p1714118940393719?thread_ts=1714079460.781409&cid=C5FAE2LL9
        #if os(macOS)
        options.executablePath = arguments.tool

        //  Guess the SDK if not specified.
        options.swiftSDK = options.swiftSDK ?? .macOS

        #endif

        return options
    }
}
extension Unidoc.Build
{
    private
    func local() async throws
    {
        guard
        let project:Symbol.Package = self.project
        else
        {
            fatalError("No project specified")
        }

        let search:FilePath? = self.input.map(FilePath.init(_:))
        let type:SSGC.ProjectType = self.book ? .book : .package

        let unidoc:Unidoc.Client<HTTP.Client1> = try .init(from: self)
        try await unidoc.buildAndUpload(local: project, search: search, type: type)
    }
}
