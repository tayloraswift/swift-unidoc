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
    func uplink(editions:FilePath) async throws
    {
        let json:JSON = .init(utf8: try editions.read())
        let coordinates:[Coordinates] = try json.decode()
        for coordinates:Coordinates in coordinates.sorted()
        {
            try await self.connect
            {
                @Sendable (connection:SwiftinitClient.Connection) in

                do
                {
                    try await connection.uplink(
                        package: coordinates.package,
                        version: coordinates.version)

                    print("Successfully uplinked symbol graph \(coordinates)")
                }
                catch let error
                {
                    print("Failed to uplink \(coordinates): \(error)")
                }
            }
        }
    }
    func uplink(package symbol:Symbol.Package) async throws
    {
        try await self.connect
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            let package:Unidoc.PackageStatus = try await connection.status(
                of: symbol)

            try await connection.uplink(
                package: package.coordinate,
                version: package.release.coordinate)

            print("Successfully uplinked symbol graph!")
        }
    }

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
        force:Bool) async throws
    {
        //  Building the package might take a long time, and the server might close the
        //  connection before the build is finished. So we do not try to keep this
        //  connection open.
        let package:Unidoc.PackageStatus? = try await self.connect
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            do
            {
                return try await connection.status(of: symbol)
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
        let package:Unidoc.PackageStatus
        else
        {
            print("Not a buildable package.")
            return
        }

        let toolchain:Toolchain = try await .detect()
        let workspace:SPM.Workspace = try await .create(at: ".swiftinit")

        guard
        let edition:Unidoc.PackageStatus.Edition = package.choose(force: force)
        else
        {
            print("""
                No new documentation to build, run with -f to force upload of \
                unindexed documentation.
                """)
            return
        }

        let build:SPM.Build = try await .remote(
            package: symbol,
            from: package.repo,
            at: edition.tag,
            in: workspace,
            clean: [.artifacts])

        let archive:SymbolGraphObject<Void> = try await .init(building: build,
            with: toolchain,
            pretty: pretty)

        let bson:BSON.Document = .init(encoding: Unidoc.Snapshot.init(id: .init(
                package: package.coordinate,
                version: edition.coordinate),
            metadata: archive.metadata,
            inline: archive.graph,
            link: force ? .refresh : .initial))

        try await self.connect
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            print("Uploading symbol graph...")

            try await connection.put(bson: bson, to: "/api/snapshot")

            print("Successfully uploaded symbol graph!")
        }
    }
}
