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

@frozen public
struct SwiftinitClient
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
extension SwiftinitClient
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
extension SwiftinitClient
{
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        try await self.connect { try await $0.get(from: endpoint) }
    }
}
extension SwiftinitClient
{
    func build(local symbol:Symbol.Package,
        search:FilePath?,
        pretty:Bool) async throws
    {
        let toolchain:Toolchain = try await .detect()
        let workspace:SPM.Workspace = try await .create(at: ".swiftinit")

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
            @Sendable (connection:SwiftinitClient.Connection) in

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
            @Sendable (connection:SwiftinitClient.Connection) in

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
                link: force != nil ? .refresh : .initial)
        }
        else
        {
            print("Not a buildable package.")
        }
    }

    private
    func build(_ buildable:Unidoc.BuildArguments,
        pretty:Bool,
        link:Unidoc.Snapshot.LinkState) async throws
    {
        let toolchain:Toolchain = try await .detect()
        let workspace:SPM.Workspace = try await .create(at: ".swiftinit")

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
            link: link))

        try await self.connect
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            print("Uploading symbol graph...")

            try await connection.put(bson: bson, to: "/api/snapshot")

            print("Successfully uploaded symbol graph!")
        }
    }
}
extension SwiftinitClient
{
    func upgrade(pretty:Bool) async throws
    {
        let editions:[Unidoc.Edition] = try await self.connect
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            try await connection.oldest(until: SymbolGraphABI.version)
        }

        for edition:Unidoc.Edition in editions where edition.version != -1
        {
            let buildable:Unidoc.BuildArguments
            do
            {
                buildable = try await self.connect
                {
                    @Sendable (connection:SwiftinitClient.Connection) in

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

            try await self.build(buildable,
                pretty: pretty,
                link: .refresh)
        }
    }
}
