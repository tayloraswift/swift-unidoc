import BSON
import HTTPClient
import JSON
import SymbolGraphBuilder
import SymbolGraphs
import Symbols
import System
import UnidocAutomation
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

            let package:UnidocAPI.PackageStatus = try await connection.status(
                of: symbol)

            try await connection.uplink(
                package: package.coordinate,
                version: package.release.coordinate)

            print("Successfully uplinked symbol graph!")
        }
    }

    func build(
        package symbol:Symbol.Package,
        pretty:Bool,
        force:Bool,
        input:FilePath?) async throws
    {
        //  Building the package might take a long time, and the server might close the
        //  connection before the build is finished. So we do not try to keep this
        //  connection open.
        let package:UnidocAPI.PackageStatus? = symbol == .swift
            ? nil
            : try await self.connect
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

        let toolchain:Toolchain = try await .detect()
        let workspace:Workspace = try await .create(at: ".swiftinit")

        if  let package:UnidocAPI.PackageStatus
        {
            guard
            let edition:UnidocAPI.PackageStatus.Edition = package.choose(force: force)
            else
            {
                print("No new documentation to build.")
                return
            }

            let build:PackageBuild = try await .remote(
                package: symbol,
                from: package.repo,
                at: edition.tag,
                in: workspace,
                clean: true)

            //  Remove the `Package.resolved` file to force a new resolution.
            try await build.removePackageResolved()

            let archive:SymbolGraphArchive = try await toolchain.generateDocs(for: build,
                pretty: pretty)

            let bson:BSON.Document = .init(encoding: Realm.Snapshot.init(id: .init(
                    package: package.coordinate,
                    version: edition.coordinate),
                metadata: archive.metadata,
                graph: archive.graph))

            try await self.connect
            {
                @Sendable (connection:SwiftinitClient.Connection) in

                print("Uploading symbol graph...")

                try await connection.put(bson: bson, to: "/api/snapshot")

                print("Successfully uploaded symbol graph!")

                try await connection.uplink(
                    package: package.coordinate,
                    version: edition.coordinate)

                print("Successfully uplinked symbol graph!")
            }
        }
        else if force
        {
            let archive:SymbolGraphArchive
            if  symbol == .swift
            {
                let build:ToolchainBuild = try await .swift(in: workspace,
                    clean: true)

                archive = try await toolchain.generateDocs(for: build, pretty: pretty)
            }
            else if
                let project:FilePath = input
            {
                let build:PackageBuild = try await .local(package: symbol,
                    from: project,
                    in: workspace,
                    clean: true)

                archive = try await toolchain.generateDocs(for: build, pretty: pretty)
            }
            else
            {
                fatalError("No project path specified.")
            }

            let bson:BSON.Document = .init(encoding: consume archive)

            try await self.connect
            {
                @Sendable (connection:SwiftinitClient.Connection) in

                print("Uploading symbol graph...")

                let placement:UnidocAPI.Placement = try await connection.put(bson: bson,
                    to: "/api/symbolgraph")

                print("Successfully uploaded symbol graph!")

                try await connection.uplink(
                    package: placement.edition.package,
                    version: placement.edition.version)

                print("Successfully uplinked symbol graph!")
            }
        }
        else
        {
            print("""
                No new documentation to build, run with -f to force upload of \
                unindexed documentation.
                """)
        }
    }
}
