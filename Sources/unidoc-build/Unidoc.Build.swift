#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

import ArgumentParsing
import HTTP
import SymbolGraphs
import Symbols
import System
import Unidoc
import UnidocAPI

extension Unidoc
{
    struct Build:Sendable
    {
        var package:Symbol.Package?
        var cookie:String
        var host:String
        var port:Int

        var pretty:Bool
        var executablePath:String?
        var swiftRuntime:String?
        var swiftPath:String?
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
            self.executablePath = nil
            self.swiftRuntime = nil
            self.swiftPath = nil
            self.swiftSDK = nil
            self.force = nil
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
            setlinebuf(stdout)
            SSGC.main(arguments: arguments)
            return
        }

        do
        {
            let build:Self = try .parse(arguments: arguments)

            switch command
            {
            case "requests":
                try await build.requests()

            case "local":
                try await build.local()

            case "latest":
                try await build.latest()

            case let command:
                print("Unknown command: \(command)")
                SystemProcess.exit(with: 1)
            }
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

            case "--swift-runtime", "-r":
                options.swiftRuntime = try arguments.next(for: option)

            case "--swift", "-s":
                options.swiftPath = try arguments.next(for: option)

            case "--swift-sdk", "-k":
                options.swiftSDK = try arguments.next(for: option)

            case "--input", "-I":
                options.input = try arguments.next(for: option)

            case "--force", "-f":
                options.force = .release

            case "--force-prerelease", "-e":
                options.force = .prerelease

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
    func requests() async throws
    {
        let unidoc:Unidoc.Client = try .init(from: self)
        let cache:FilePath = "swiftpm"

        /// TODO: make configurable
        let pollInterval:Duration = .seconds(60 * 60)

        while true
        {
            //  Don’t run too hot if the network is down.
            async
            let cooldown:Void = try await Task.sleep(for: .seconds(5))
            do
            {
                let labels:Unidoc.BuildLabels = try await unidoc.connect
                {
                    try await $0.labels(waiting: pollInterval)
                }

                print("""
                    Building package '\(labels.package)' at '\(labels.ref)' \
                    (\(labels.coordinate))
                    """)

                /// As this runs continuously, we should remove the build artifacts afterwards,
                /// to avoid filling up the disk. We must also remove the cloned repository,
                /// as it may experience name conflicts on long timescales.
                try await unidoc.buildAndUpload(
                    labels: labels,
                    action: .uplinkRefresh,
                    remove: true,
                    cache: cache)

                try await cooldown
            }
            catch let error
            {
                print("Error: \(error)")
                try await cooldown
            }
        }
    }

    private
    func local() async throws
    {
        let unidoc:Unidoc.Client = try .init(from: self)

        guard
        let package:Symbol.Package = self.package
        else
        {
            fatalError("No package specified")
        }

        try await unidoc.buildAndUpload(local: package,
            search: self.input.map(FilePath.init(_:)))
    }

    private
    func latest() async throws
    {
        let unidoc:Unidoc.Client = try .init(from: self)

        guard
        let package:Symbol.Package = self.package
        else
        {
            print("No package specified!")
            return
        }

        let labels:Unidoc.BuildLabels? = try await unidoc.connect
        {
            try await $0.labels(of: package, series: self.force ?? .release)
        }

        guard
        let labels:Unidoc.BuildLabels
        else
        {
            print("Package '\(package)' is not buildable by labels!")
            return
        }

        try await unidoc.buildAndUpload(
            labels: labels,
            action: self.force != nil ? .uplinkRefresh : .uplinkInitial)
    }
}
