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
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        try await self.connect { try await $0.get(from: endpoint) }
    }
}
extension Unidoc.Client
{
    func build(local symbol:Symbol.Package,
        search:FilePath?,
        pretty:Bool,
        swift:String?) async throws
    {
        let toolchain:Toolchain = try await .detect(swift: swift ?? "swift")
        let workspace:SPM.Workspace = try await .create(at: ".unidoc")

        let archive:SymbolGraphObject<Void>
        if  symbol == .swift
        {
            let build:Toolchain.Build = try await .swift(in: workspace,
                clean: true)

            archive = try await .init(building: build, with: toolchain, pretty: pretty)
        }
        else if
            let search:FilePath
        {
            let build:SPM.Build = try await .local(package: symbol,
                from: search,
                in: workspace,
                clean: true)

            archive = try await .init(building: build, with: toolchain, pretty: pretty)
        }
        else
        {
            fatalError("No package search path specified.")
        }
        //  https://github.com/apple/swift/issues/71607
        let bson:BSON.Document = .init(encoding: /* consume */ archive)

        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            print("Uploading symbol graph...")

            let _:Unidoc.UploadStatus = try await connection.put(bson: bson,
                to: "/api/symbolgraph")

            print("Successfully uploaded symbol graph!")
        }
    }

    func build(remote symbol:Symbol.Package,
        pretty:Bool,
        force:Unidoc.BuildLatest?) async throws
    {
        //  Building the package might take a long time, and the server might close the
        //  connection before the build is finished. So we do not try to keep this
        //  connection open.
        let buildable:Unidoc.BuildArguments? = try await self.connect
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
        if  let buildable:Unidoc.BuildArguments
        {
            try await self.build(buildable,
                pretty: pretty,
                action: force != nil ? .uplinkRefresh : .uplinkInitial)
        }
        else
        {
            print("Not a buildable package.")
        }
    }

    private
    func build(_ buildable:Unidoc.BuildArguments,
        pretty:Bool,
        action:Unidoc.Snapshot.PendingAction) async throws
    {
        let toolchain:Toolchain = try await .detect()
        let workspace:SPM.Workspace = try await .create(at: ".unidoc")

        guard
        let tag:String = buildable.tag
        else
        {
            print("""
                No new documentation to build, run with -f or -e to build the latest release
                or prerelease anyway.
                """)
            return
        }

        let build:SPM.Build = try await .remote(
            package: buildable.package,
            from: buildable.repo,
            at: tag,
            in: workspace,
            clean: [.artifacts])

        let archive:SymbolGraphObject<Void> = try await .init(building: build,
            with: toolchain,
            pretty: pretty)

        let bson:BSON.Document = .init(encoding: Unidoc.Snapshot.init(id: buildable.coordinate,
            metadata: archive.metadata,
            inline: archive.graph,
            action: action))

        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            print("Uploading symbol graph...")

            try await connection.put(bson: bson, to: "/api/snapshot")

            print("Successfully uploaded symbol graph!")
        }
    }
}
extension Unidoc.Client
{
    func upgrade(pretty:Bool) async throws
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

                let buildable:Unidoc.BuildArguments
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

                do
                {
                    try await self.build(buildable,
                        pretty: pretty,
                        action: .uplinkRefresh)

                    upgraded += 1
                }
                catch SPM.BuildError.swift_build
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
