import BSON
import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import SymbolGraphBuilder
import SymbolGraphs
import System
import UnidocAutomation
import UnidocLinker
import UnidocRecords

@main
enum Main
{
    static
    func main() async throws
    {
        let options:Options = try .parse()

        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        //  If we are not using the default port, we are probably running locally.
        if  options.port != 443
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: options.remote)

        let swiftinit:SwiftinitClient = .init(http2: http2, cookie: options.cookie)

        guard options.build
        else
        {
            //  Uplink only.
            return try await swiftinit.connect(port: options.port)
            {
                @Sendable (connection:SwiftinitClient.Connection) in

                let package:UnidocAPI.PackageStatus = try await connection.status(
                    of: options.package)

                try await connection.uplink(
                    package: package.coordinate,
                    version: package.release.coordinate)

                print("Successfully uplinked symbol graph!")
            }
        }

        //  Building the package might take a long time, and the server might close the
        //  connection before the build is finished. So we do not try to keep this
        //  connection open.
        let package:UnidocAPI.PackageStatus? = options.package == .swift
            ? nil
            : try await swiftinit.connect(port: options.port)
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            do
            {
                return try await connection.status(of: options.package)
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
            let edition:UnidocAPI.PackageStatus.Edition = package.choose(force: options.force)
            else
            {
                print("No new documentation to build.")
                return
            }

            let build:PackageBuild = try await .remote(
                package: options.package,
                from: package.repo,
                at: edition.tag,
                in: workspace,
                clean: true)

            //  Remove the `Package.resolved` file to force a new resolution.
            try await build.removePackageResolved()

            let archive:SymbolGraphArchive = try await toolchain.generateDocs(for: build,
                pretty: options.pretty)

            let bson:BSON.Document = .init(encoding: Realm.Snapshot.init(id: .init(
                    package: package.coordinate,
                    version: edition.coordinate),
                metadata: archive.metadata,
                graph: archive.graph))

            try await swiftinit.connect(port: options.port)
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
        else if options.force
        {
            let archive:SymbolGraphArchive
            if  options.package == .swift
            {
                let build:ToolchainBuild = try await .swift(in: workspace,
                    clean: true)

                archive = try await toolchain.generateDocs(for: build, pretty: options.pretty)
            }
            else if
                let project:FilePath = options.input.map(FilePath.init(_:))
            {
                let build:PackageBuild = try await .local(package: options.package,
                    from: project,
                    in: workspace,
                    clean: true)

                archive = try await toolchain.generateDocs(for: build, pretty: options.pretty)
            }
            else
            {
                fatalError("No project path specified.")
            }

            let bson:BSON.Document = .init(encoding: consume archive)

            try await swiftinit.connect(port: options.port)
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
