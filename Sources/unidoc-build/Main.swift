#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#else
#error("unsupported platform")
#endif

import HTTP
import SymbolGraphs
import Symbols
import System
import UnidocAPI

@MainActor
@main
extension Unidoc
{
    @MainActor static
    func main() async
    {
        do
        {
            var arguments:CommandLine.Arguments = .init()
            switch arguments.next()
            {
            case "build"?:
                SSGC.main(arguments: arguments)

            case "builder"?:
                try await Self.builder(arguments: arguments)

            case "latest"?:
                try await Self.latest(arguments: arguments)

            case "upgrade"?:
                try await Self.upgrade(arguments: arguments)

            case let command?:
                print("Unknown command: \(command)")
                exit(1)

            case nil:
                print("No command specified")
                exit(1)
            }
        }
        catch let error
        {
            print("Error: \(error)")
            exit(255)
        }
    }
}
extension Unidoc
{
    private static
    func builder(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)

        let toolchain:SSGC.Toolchain = try options.toolchain()
        let unidoc:Client = try options.client()

        while true
        {
            //  Don’t run too hot if the network is down.
            async
            let cooldown:Void = try await Task.sleep(for: .seconds(5))
            do
            {
                try await unidoc.buildAndUploadQueued(toolchain: toolchain)
                try await cooldown
            }
            catch let error
            {
                print("Error: \(error)")
                try await cooldown
            }
        }
    }

    private static
    func latest(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)

        let toolchain:SSGC.Toolchain = try options.toolchain()
        let unidoc:Client = try options.client()

        guard
        let package:Symbol.Package = options.package
        else
        {
            fatalError("No package specified")
        }

        if  package != .swift,
            options.input == nil
        {
            try await unidoc.buildAndUpload(remote: package,
                force: options.force,
                toolchain: toolchain)
        }
        else
        {
            try await unidoc.buildAndUpload(local: package,
                search: options.input.map(FilePath.init(_:)),
                toolchain: toolchain)
        }
    }

    private static
    func upgrade(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)

        let toolchain:SSGC.Toolchain = try options.toolchain()
        let unidoc:Client = try options.client()

        var unbuildable:[Unidoc.Edition: ()] = [:]

        upgrading:
        do
        {
            let editions:[Unidoc.Edition] = try await unidoc.connect
            {
                @Sendable (connection:Unidoc.Client.Connection) in

                try await connection.oldest(until: SymbolGraphABI.version)
            }

            var upgraded:Int = 0

            for edition:Unidoc.Edition in editions where edition.version != -1
            {
                if  unbuildable.keys.contains(edition)
                {
                    continue
                }

                let labels:Unidoc.BuildLabels
                do
                {
                    labels = try await unidoc.connect
                    {
                        @Sendable (connection:Unidoc.Client.Connection) in

                        try await connection.build(id: edition)
                    }
                }
                catch let error as HTTP.StatusError
                {
                    guard
                    case 404? = error.code
                    else
                    {
                        throw error
                    }

                    print("No buildable package for \(edition).")
                    continue
                }

                if  case .swift = labels.package
                {
                    //  We cannot build the standard library this way.
                    print("Skipping 'swift'")
                    continue
                }

                if  case .success(let snapshot) = try await Unidoc.Build.with(
                        toolchain: toolchain,
                        labels: labels,
                        action: .uplinkRefresh)
                {
                    try await unidoc.connect
                    {
                        @Sendable (connection:Unidoc.Client.Connection) in

                        try await connection.upload(snapshot)
                    }

                    upgraded += 1
                }
                else
                {
                    print("Failed to build \(labels.package) \(labels.tag ?? "?")")
                    unbuildable[edition] = ()
                }
            }
            //  If we have upgraded at least one package, there are probably more.
            if  upgraded > 0
            {
                continue upgrading
            }
        }
    }
}
