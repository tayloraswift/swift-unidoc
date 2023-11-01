import BSON
import HTTPClient
import ModuleGraphs
import NIOCore
import NIOPosix
import NIOSSL
import SemanticVersions
import SymbolGraphBuilder
import SymbolGraphs
import System
import UnidocAutomation
import UnidocLinker

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

                let package:PackageBuildStatus = try await connection.status(
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
        let package:PackageBuildStatus = try await swiftinit.connect(port: options.port)
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            try await connection.status(of: options.package)
        }

        let toolchain:Toolchain = try await .detect()
        let workspace:Workspace = try await .create(at: ".swiftinit")
        let edition:PackageBuildStatus.Edition

        /// Only build prereleases if the latest release has already been built, and
        /// the prerelease has a higher patch version.
        if  package.release.graphs == 0 || options.force
        {
            edition = package.release
        }
        else if
            let prerelease:PackageBuildStatus.Edition = package.prerelease,
                prerelease.graphs == 0,
            let version:SemanticVersion = .init(refname: prerelease.tag),
            let release:SemanticVersion = .init(refname: package.release.tag),
                release.patch < version.patch
        {
            edition = prerelease
        }
        else
        {
            print("No new documentation to build")
            return
        }

        let archive:SymbolGraphArchive

        if  options.package == .swift
        {
            let build:ToolchainBuild = try await .swift(in: workspace,
                clean: true)


            archive = try await toolchain.generateDocs(for: build,
                pretty: options.pretty)
        }
        else
        {
            let build:PackageBuild = try await .remote(
                package: options.package,
                from: package.repo,
                at: edition.tag,
                in: workspace,
                clean: true)
            //  Remove the `Package.resolved` file to force a new resolution.
            try await build.removePackageResolved()

            archive = try await toolchain.generateDocs(for: build,
                pretty: options.pretty)
        }

        if  let output:FilePath = options.output.map(FilePath.init(_:))
        {
            let bson:BSON.Document = .init(encoding: consume archive)
            try output.overwrite(with: bson.bytes)
            return
        }

        if  let tag:String = archive.metadata.commit?.refname,
                tag != edition.tag
        {
            fatalError("Tag mismatch: \(tag) != \(edition.tag)")
        }

        let snapshot:Snapshot = .init(
            package: package.coordinate,
            version: edition.coordinate,
            archive: archive)

        let bson:BSON.Document = .init(encoding: consume snapshot)

        try await swiftinit.connect(port: options.port)
        {
            @Sendable (connection:SwiftinitClient.Connection) in

            print("Uploading symbol graph...")

            try await connection.put(bson: bson, to: "/api/symbolgraph")

            print("Successfully uploaded symbol graph (tag: \(edition.tag))")

            try await connection.uplink(
                package: package.coordinate,
                version: edition.coordinate)

            print("Successfully uplinked symbol graph!")
        }
    }
}
