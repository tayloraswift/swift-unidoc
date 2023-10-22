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
        if  options.remote == "localhost"
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: options.remote)

        let swiftinit:SwiftinitClient = .init(http2: http2, cookie: options.cookie)

        try await swiftinit.connect(port: options.port)
        {
            let package:PackageBuildStatus = try await $0.get(
                from: "/api/build/\(options.package)")

            let toolchain:Toolchain = try await .detect()
            let workspace:Workspace = try await .create(at: ".swiftinit")

            let edition:PackageBuildStatus.Edition

            if  options.build
            {
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
                }
                else
                {
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
                    print("Uploading symbol graph...")

                    try await $0.put(bson: bson, to: "/api/symbolgraph")

                    print("Successfully uploaded symbol graph (tag: \(edition.tag))")
                }
            }
            else
            {
                edition = package.release
            }

            if  case nil = options.output
            {
                try await $0.post(
                    urlencoded: "package=\(package.coordinate)&version=\(edition.coordinate)",
                    to: "/api/uplink")
            }
        }
    }
}
