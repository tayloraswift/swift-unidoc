import BSON
import HTTPClient
import JSON
import SymbolGraphBuilder
import SymbolGraphs
import Symbols
import System
import UnidocAPI
import UnidocLinker
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Client
    {
        @usableFromInline internal
        let http2:HTTP2Client
        @usableFromInline internal
        let port:Int
        @usableFromInline internal
        let cookie:String

        @inlinable public
        init(http2:HTTP2Client, cookie:String, port:Int)
        {
            self.http2 = http2
            self.cookie = cookie
            self.port = port
        }
    }
}
extension Unidoc.Client
{
    @inlinable public
    func connect<T>(with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http2.connect(port: self.port)
        {
            try await body(Connection.init(http2: $0, cookie: self.cookie))
        }
    }
}
extension Unidoc.Client
{
    func buildAndUpload(local symbol:Symbol.Package,
        search:FilePath?,
        pretty:Bool,
        toolchain:SSGC.Toolchain) async throws
    {
        let workspace:SSGC.Workspace = try await .create(at: ".unidoc")

        let object:SymbolGraphObject<Void>
        if  symbol == .swift
        {
            let build:SSGC.StdlibBuild = try await .swift(in: workspace,
                clean: true)

            object = try await .init(building: build, with: toolchain, pretty: pretty)
        }
        else if
            let search:FilePath
        {
            let build:SSGC.PackageBuild = try await .local(package: symbol,
                from: search,
                in: workspace,
                clean: true)

            object = try await .init(building: build, with: toolchain, pretty: pretty)
        }
        else
        {
            fatalError("No package search path specified.")
        }

        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            try await connection.upload(object)
        }
    }

    func buildAndUpload(remote symbol:Symbol.Package,
        pretty:Bool,
        force:Unidoc.VersionSeries?,
        toolchain:SSGC.Toolchain) async throws
    {
        //  Building the package might take a long time, and the server might close the
        //  connection before the build is finished. So we do not try to keep this
        //  connection open.
        let labels:Unidoc.BuildLabels? = try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            do
            {
                return try await connection.latest(force, of: symbol)
            }
            catch let error as HTTP.StatusError
            {
                guard
                case 404? = error.code
                else
                {
                    throw error
                }

                return nil
            }
        }

        guard
        let labels:Unidoc.BuildLabels
        else
        {
            print("Not a buildable package.")
            return
        }

        let result:Result<Unidoc.Snapshot, Unidoc.BuildFailure> = try await self.build(labels,
            action: force != nil ? .uplinkRefresh : .uplinkInitial,
            pretty: pretty,
            toolchain: toolchain)


        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            switch result
            {
            case .success(let labeled):
                try await connection.upload(labeled)

            case .failure(let failure):
                try await connection.upload(.init(
                    package: labels.coordinate.package,
                    failure: failure))
            }
        }
    }

    private
    func buildAndUploadQueued(toolchain:SSGC.Toolchain) async throws
    {
        let labels:Unidoc.BuildLabels = try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            try await connection.get(from: "/ssgc/poll", timeout: .seconds(60 * 60))
        }

        print("""
            Building package '\(labels.package)' at '\(labels.tag ?? "?")' \
            (\(labels.coordinate))
            """)

        let result:Result<Unidoc.Snapshot, Unidoc.BuildFailure> = try await self.build(labels,
            action: .uplinkRefresh,
            pretty: false,
            toolchain: toolchain)

        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            switch result
            {
            case .success(let labeled):
                try await connection.upload(labeled)

            case .failure(let failure):
                try await connection.upload(.init(
                    package: labels.coordinate.package,
                    failure: failure))
            }
        }
    }

    private
    func build(_ labels:Unidoc.BuildLabels,
        action:Unidoc.Snapshot.PendingAction,
        pretty:Bool,
        toolchain:SSGC.Toolchain) async throws -> Result<Unidoc.Snapshot, Unidoc.BuildFailure>
    {
        let workspace:SSGC.Workspace = try await .create(at: ".unidoc")

        guard
        let tag:String = labels.tag
        else
        {
            print("""
                No new documentation to build, run with -f or -e to build the latest release
                or prerelease anyway.
                """)

            return .failure(.init(reason: .noValidVersion))
        }

        guard
        let build:SSGC.PackageBuild = try? await .remote(
            package: labels.package,
            from: labels.repo,
            at: tag,
            in: workspace,
            clean: [.artifacts])
        else
        {
            return .failure(.init(reason: .failedToCloneRepository))
        }

        do
        {
            let archive:SymbolGraphObject<Void> = try await .init(building: build,
                with: toolchain,
                pretty: pretty)

            return .success(Unidoc.Snapshot.init(id: labels.coordinate,
                metadata: archive.metadata,
                inline: archive.graph,
                action: action))
        }
        catch let error as SSGC.ManifestDumpError
        {
            return .failure(.init(reason: error.leaf ?
                    .failedToReadManifest :
                    .failedToReadManifestForDependency))
        }
        catch let error as SSGC.PackageBuildError
        {
            print("Error: \(error)")

            let reason:Unidoc.BuildFailure.Reason

            switch error
            {
            case .swift_package_update:         reason = .failedToResolveDependencies
            case .swift_build:                  reason = .failedToCompile
            case .swift_symbolgraph_extract:    reason = .failedToCompile
            }

            return .failure(.init(reason: reason))
        }
    }
}
extension Unidoc.Client
{
    func builder(toolchain:SSGC.Toolchain) async throws
    {
        while true
        {
            //  Don’t run too hot if the network is down.
            async
            let cooldown:Void = try await Task.sleep(for: .seconds(5))
            do
            {
                try await self.buildAndUploadQueued(toolchain: toolchain)
                try await cooldown
            }
            catch let error
            {
                print("Error: \(error)")
                try await cooldown
            }
        }
    }

    func upgrade(toolchain:SSGC.Toolchain, pretty:Bool) async throws
    {
        var unbuildable:[Unidoc.Edition: ()] = [:]

        upgrading:
        do
        {
            let editions:[Unidoc.Edition] = try await self.connect
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

                let buildable:Unidoc.BuildLabels
                do
                {
                    buildable = try await self.connect
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

                if  case .swift = buildable.package
                {
                    //  We cannot build the standard library this way.
                    print("Skipping 'swift'")
                    continue
                }

                if  case .success(let snapshot) = try await self.build(buildable,
                        action: .uplinkRefresh,
                        pretty: pretty,
                        toolchain: toolchain)
                {
                    try await self.connect
                    {
                        @Sendable (connection:Unidoc.Client.Connection) in

                        try await connection.upload(snapshot)
                    }

                    upgraded += 1
                }
                else
                {
                    print("Failed to build \(buildable.package) \(buildable.tag ?? "?")")
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
