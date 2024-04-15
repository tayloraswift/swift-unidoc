import BSON
import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import SymbolGraphBuilder
import SymbolGraphs
import Symbols
import System
import UnidocAPI
import UnidocRecords

extension Unidoc
{
    struct Client:Sendable
    {
        private
        let swiftPath:String?
        private
        let swiftSDK:SSGC.AppleSDK?
        private
        let pretty:Bool
        private
        let cookie:String

        let http2:HTTP2Client
        let port:Int

        private
        init(
            swiftPath:String?,
            swiftSDK:SSGC.AppleSDK?,
            pretty:Bool,
            cookie:String,
            http2:HTTP2Client,
            port:Int)
        {
            self.swiftPath = swiftPath
            self.swiftSDK = swiftSDK
            self.pretty = pretty
            self.cookie = cookie
            self.http2 = http2
            self.port = port
        }
    }
}
extension Unidoc.Client
{
    init(from options:Unidoc.Options) throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        //  If we are not using the default port, we are probably running locally.
        if  options.port != 443
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        print("Connecting to \(options.host):\(options.port)...")

        self.init(
            swiftPath: options.swift,
            swiftSDK: options.swiftSDK,
            pretty: options.pretty,
            cookie: options.cookie,
            http2: .init(threads: threads,
                niossl: niossl,
                remote: options.host),
            port: options.port)
    }
}
extension Unidoc.Client
{
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
    /// Listens for SSGC updates over the provided pipe, uploading any intermediate reports to
    /// Unidoc server and returning the final report, without uploading it.
    private
    func stream(from pipe:FilePath, package:Unidoc.Package) async throws -> Unidoc.BuildReport
    {
        try await SSGC.StatusStream.read(from: pipe)
        {
            //  Acknowledge the build request.
            try await self.connect
            {
                try await $0.upload(.init(package: package, entered: .cloningRepository))
            }

            while let update:SSGC.StatusUpdate = try $0.next()
            {
                var report:Unidoc.BuildReport = .init(package: package)
                switch update
                {
                case .didCloneRepository:
                    report.entered = .resolvingDependencies

                case .didResolveDependencies:
                    report.entered = .compilingCode

                case .failedToCloneRepository:
                    report.failure = .failedToCloneRepository

                case .failedToReadManifest:
                    report.failure = .failedToReadManifest

                case .failedToReadManifestForDependency:
                    report.failure = .failedToReadManifestForDependency

                case .failedToResolveDependencies:
                    report.failure = .failedToResolveDependencies

                case .failedToBuild:
                    report.failure = .failedToBuild

                case .failedToExtractSymbolGraph:
                    report.failure = .failedToExtractSymbolGraph

                case .failedToLoadSymbolGraph:
                    report.failure = .failedToLoadSymbolGraph

                case .failedToLinkSymbolGraph:
                    report.failure = .failedToLinkSymbolGraph

                case .success:
                    return report
                }

                if  case nil = report.failure
                {
                    try await self.connect { try await $0.upload(report) }
                    continue
                }
                else
                {
                    return report
                }
            }

            throw SSGC.StatusUpdateError.init()
        }
    }

    @discardableResult
    func buildAndUpload(
        labels:Unidoc.BuildLabels,
        action:Unidoc.Snapshot.PendingAction) async throws -> Bool
    {
        guard
        let tag:String = labels.tag
        else
        {
            print("""
                No new documentation to build, run with -f or -e to build the latest release
                or prerelease anyway.
                """)

            let reportNoneBuildable:Unidoc.BuildReport =  .init(
                package: labels.coordinate.package,
                failure: .noValidVersion,
                entered: nil,
                logs: [])

            try await self.connect { try await $0.upload(reportNoneBuildable) }
            return false
        }

        let workspace:SSGC.Workspace = try .create(at: ".unidoc")

        let diagnostics:FilePath = workspace.path / "docs.log"
        let docs:FilePath = workspace.path / "docs.bson"
        let output:FilePath = workspace.path / "output"
        let status:FilePath = workspace.path / "status"

        try SystemProcess.init(command: "rm", "-f", "\(status)")()
        try SystemProcess.init(command: "mkfifo", "\(status)")()

        defer
        {
            try? SystemProcess.init(command: "rm", "\(status)")()
        }

        var arguments:[String] = [
            "build",

            "--package-name", "\(labels.package)",
            "--package-repo", labels.repo,
            "--tag", tag,
            "--workspace", "\(workspace.path)",
            "--status", "\(status)",
            "--output", "\(docs)",
            "--output-log", "\(diagnostics)"
        ]
        if  self.pretty
        {
            arguments.append("--pretty")
        }
        if  let swift:String = self.swiftPath
        {
            arguments.append("--swift")
            arguments.append("\(swift)")
        }
        if  let sdk:SSGC.AppleSDK = self.swiftSDK
        {
            arguments.append("--sdk")
            arguments.append("\(sdk)")
        }

        let ssgc:SystemProcess = try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try .init(command: nil,
                arguments: arguments,
                stdout: $0,
                stderr: $0)
        }

        async
        let updates:Unidoc.BuildReport = try self.stream(from: status,
            package: labels.coordinate.package)

        //  Wait for the child process to finish.
        try ssgc()

        var report:Unidoc.BuildReport = try await updates

        try report.attach(log: output, as: .ssgc)
        try report.attach(log: diagnostics, as: .ssgcDiagnostics)

        if  case _? = report.failure
        {
            try await self.connect { try await $0.upload(report) }
            return false
        }
        else
        {
            let object:SymbolGraphObject<Void> = try .init(buffer: try docs.read())
            //  We want to upload the symbol graph first, mainly so that the server does not
            //  need to handle a state where the build is allegedly successful, but the symbol
            //  graph is not available yet.
            try await self.connect
            {
                try await $0.upload(Unidoc.Snapshot.init(id: labels.coordinate,
                    metadata: object.metadata,
                    inline: object.graph,
                    action: action))

                try await $0.upload(report)
            }

            return true
        }
    }

    func buildAndUpload(local symbol:Symbol.Package, search:FilePath?) async throws
    {
        let workspace:SSGC.Workspace = try .create(at: ".unidoc")
        let docs:FilePath = workspace.path / "docs.bson"

        var arguments:[String] = [
            "build",

            "--package-name", "\(symbol)",
            "--workspace", "\(workspace.path)",
            "--output", "\(docs)",
        ]
        if  self.pretty
        {
            arguments.append("--pretty")
        }
        if  let swift:String = self.swiftPath
        {
            arguments.append("--swift")
            arguments.append("\(swift)")
        }
        if  let sdk:SSGC.AppleSDK = self.swiftSDK
        {
            arguments.append("--sdk")
            arguments.append("\(sdk)")
        }
        if  let search:FilePath = search
        {
            arguments.append("--search-path")
            arguments.append("\(search)")
        }

        let ssgc:SystemProcess = try .init(command: nil, arguments: arguments)
        try ssgc()

        let object:SymbolGraphObject<Void> = try .init(buffer: try docs.read())

        try await self.connect { try await $0.upload(object) }
    }
}
