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

            case "package"?:
                try await Self.package(arguments: arguments)

            case "latest"?:
                try await Self.latest(arguments: arguments)

            case "upgrade"?:
                try await Self.upgrade(arguments: arguments)

            case let command?:
                print("Unknown command: \(command)")
                SystemProcess.exit(with: 1)

            case nil:
                print("No command specified")
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
extension Unidoc
{
    private static
    func builder(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)
        let unidoc:Client = try .init(from: options)

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
                    Building package '\(labels.package)' at '\(labels.tag ?? "?")' \
                    (\(labels.coordinate))
                    """)

                try await unidoc.buildAndUpload(labels: labels, action: .uplinkRefresh)
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
    func package(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)
        let unidoc:Client = try .init(from: options)

        guard
        let package:Symbol.Package = options.package
        else
        {
            fatalError("No package specified")
        }

        try await unidoc.buildAndUpload(
            local: package,
            search: options.input.map(FilePath.init(_:)))
    }

    private static
    func latest(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)
        let unidoc:Client = try .init(from: options)

        guard
        let package:Symbol.Package = options.package
        else
        {
            print("No package specified!")
            return
        }

        let labels:Unidoc.BuildLabels? = try await unidoc.connect
        {
            try await $0.labels(of: package, series: options.force ?? .release)
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
            action: options.force != nil ? .uplinkRefresh : .uplinkInitial)
    }

    private static
    func upgrade(arguments:consuming CommandLine.Arguments) async throws
    {
        let options:Options = try .parse(arguments: arguments)
        let unidoc:Client = try .init(from: options)

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

                let labels:Unidoc.BuildLabels? = try await unidoc.connect
                {
                    try await $0.labels(id: edition)
                }

                guard
                let labels:Unidoc.BuildLabels
                else
                {
                    print("No buildable package for \(edition).")

                    unbuildable[edition] = ()
                    continue
                }

                if  case .swift = labels.package
                {
                    //  We cannot build the standard library this way.
                    print("Skipping 'swift'")

                    unbuildable[edition] = ()
                    continue
                }

                if  try await unidoc.buildAndUpload(labels: labels, action: .uplinkRefresh)
                {
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
