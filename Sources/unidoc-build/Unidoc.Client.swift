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
import UnidocRecords_LZ77

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
    private
    func stream(from pipe:FilePath) throws -> Unidoc.BuildFailure.Reason?
    {
        try SSGC.StatusStream.read(from: pipe)
        {
            while let update:SSGC.StatusUpdate = try $0.next()
            {
                switch update
                {
                case .didCloneRepository:
                    continue

                case .didResolveDependencies:
                    continue

                case .success:
                    return nil

                case .failedToCloneRepository:
                    return .failedToCloneRepository

                case .failedToReadManifest:
                    return .failedToReadManifest

                case .failedToReadManifestForDependency:
                    return .failedToReadManifestForDependency

                case .failedToResolveDependencies:
                    return .failedToResolveDependencies

                case .failedToBuild:
                    return .failedToBuild

                case .failedToExtractSymbolGraph:
                    return .failedToExtractSymbolGraph

                case .failedToLoadSymbolGraph:
                    return .failedToLoadSymbolGraph

                case .failedToLinkSymbolGraph:
                    return .failedToLinkSymbolGraph
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

            let failureReport:Unidoc.BuildFailureReport =  .init(
                package: labels.coordinate.package,
                failure: .init(reason: .noValidVersion),
                logs: [])

            try await self.connect { try await $0.upload(failureReport) }
            return false
        }

        let workspace:SSGC.Workspace = try .create(at: ".unidoc")
        let output:FilePath = workspace.path / "output"
        let status:FilePath = workspace.path / "status"
        let docs:FilePath = workspace.path / "docs.bson"

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
            try .init(command: nil, arguments: arguments,
                stdout: $0,
                stderr: $0)
        }

        async
        let failure:Unidoc.BuildFailure.Reason? = try self.stream(from: status)

        //  Wait for the child process to finish.
        try ssgc()

        if  let failure:Unidoc.BuildFailure.Reason = try await failure
        {
            var failureReport:Unidoc.BuildFailureReport = .init(
                package: labels.coordinate.package,
                failure: .init(reason: failure),
                logs: [])

            let output:[UInt8] = try output.read()
            if !output.isEmpty
            {
                failureReport.logs.append(.init(
                    text: .gzip(bytes: output[...], level: 10),
                    type: .ssgc))
            }

            try await self.connect { try await $0.upload(failureReport) }
            return false
        }
        else
        {
            let object:SymbolGraphObject<Void> = try .init(
                buffer: try docs.read())

            try await self.connect
            {
                try await $0.upload(Unidoc.Snapshot.init(id: labels.coordinate,
                    metadata: object.metadata,
                    inline: object.graph,
                    action: action))
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
