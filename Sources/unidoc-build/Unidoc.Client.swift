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
        let executablePath:String?

        private
        let swiftRuntime:String?
        private
        let swiftPath:String?
        private
        let swiftSDK:SSGC.AppleSDK?
        private
        let pretty:Bool
        private
        let authorization:String?

        let http2:HTTP.Client2
        let port:Int

        private
        init(executablePath:String?,
            swiftRuntime:String?,
            swiftPath:String?,
            swiftSDK:SSGC.AppleSDK?,
            pretty:Bool,
            authorization:String?,
            http2:HTTP.Client2,
            port:Int)
        {
            self.executablePath = executablePath
            self.swiftRuntime = swiftRuntime
            self.swiftPath = swiftPath
            self.swiftSDK = swiftSDK
            self.pretty = pretty
            self.authorization = authorization
            self.http2 = http2
            self.port = port
        }
    }
}
extension Unidoc.Client
{
    init(from options:Unidoc.Build) throws
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
            executablePath: options.executablePath,
            swiftRuntime: options.swiftRuntime,
            swiftPath: options.swiftPath,
            swiftSDK: options.swiftSDK,
            pretty: options.pretty,
            authorization: options.authorization,
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
            try await body(Connection.init(http2: $0, authorization: self.authorization))
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
        //  The SSGC child process blocks until somebody opens the pipe for reading, which we do
        //  here. Sometimes, we run into errors inside the following code block, which cause us
        //  to exit prematurely, which closes the pipe. When this happens, the child process is
        //  likely to experience a Broken Pipe error.
        //
        //  Because we wait on the child process exit before we wait on the result of this
        //  function, we might observe the Broken Pipe error instead of the actual error that
        //  caused the premature exit. Therefore, we avoid throwing out of this function when
        //  possible, e.g. when failing to upload reports.
        try await SSGC.StatusStream.read(from: pipe)
        {
            //  Acknowledge the build request.
            try? await self.connect
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

                case .failedForUnknownReason:
                    report.failure = .failedForUnknownReason

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
        action:Unidoc.LinkerAction,
        remove:Bool = false,
        cache:FilePath? = nil) async throws -> Bool
    {
        if  let cache:FilePath, remove
        {
            //  Ensure the cache directory exists, solely for checking free space.
            try cache.directory.create()
            //  If there is less than 2GB of free space on the current file system, and we
            //  are using a manually-managed SwiftPM cache, we should clear it.
            let stats:FileSystemStats = try .containing(path: cache)
            let space:UInt = stats.blocksFreeForUnprivileged * stats.blockSize

            print("Free space available: \(space / 1_000_000) MB")

            if  space < 2_000_000_000
            {
                try cache.directory.remove()
            }
        }

        let workspace:SSGC.Workspace = try .create(at: "unidoc")

        let diagnostics:FilePath = workspace.location / "docs.log"
        let docs:FilePath = workspace.location / "docs.bson"
        let output:FilePath = workspace.location / "output"
        let status:FilePath = workspace.location / "status"

        try SystemProcess.init(command: "rm", "-f", "\(status)")()
        try SystemProcess.init(command: "mkfifo", "\(status)")()

        //  Delete stale artifacts
        try SystemProcess.init(command: "rm", "-f", "\(diagnostics)")()
        try SystemProcess.init(command: "rm", "-f", "\(output)")()
        try SystemProcess.init(command: "rm", "-f", "\(docs)")()

        defer
        {
            try? SystemProcess.init(command: "rm", "\(status)")()
        }

        let type:SSGC.ProjectType = labels.book ? .book : .package

        var arguments:[String] = [
            "compile",

            "--package-name", "\(labels.package)",
            "--project-type", "\(type)",
            "--project-repo", labels.repo,
            "--ref", labels.ref,
            "--workspace", "\(workspace.location)",
            "--status", "\(status)",
            "--output", "\(docs)",
            "--output-log", "\(diagnostics)"
        ]
        if  self.pretty
        {
            arguments.append("--pretty")
        }
        if  let path:String = self.swiftRuntime
        {
            arguments.append("--swift-runtime")
            arguments.append("\(path)")
        }
        if  let path:String = self.swiftPath
        {
            arguments.append("--swift")
            arguments.append("\(path)")
        }
        if  let sdk:SSGC.AppleSDK = self.swiftSDK
        {
            arguments.append("--sdk")
            arguments.append("\(sdk)")
        }
        if  let cache:FilePath
        {
            arguments.append("--swiftpm-cache")
            arguments.append("\(cache)")
        }
        if  remove
        {
            arguments.append("--remove-build")
            arguments.append("--remove-clone")
        }

        let ssgc:SystemProcess = try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try .init(command: self.executablePath,
                arguments: arguments,
                stdout: $0,
                stderr: $0)
        }

        async
        let updates:Unidoc.BuildReport = try self.stream(from: status,
            package: labels.coordinate.package)

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
            //  FIXME: For security reasons, the server does not handle batched uploads well.
            //  This is usually only a problem if the uploads are very large or the network is
            //  very slow.
            try await self.connect { try await $0.upload(report) }
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

    func buildAndUpload(local symbol:Symbol.Package,
        search:FilePath?,
        type:SSGC.ProjectType) async throws
    {
        let workspace:SSGC.Workspace = try .create(at: ".ssgc")
        let docs:FilePath = workspace.location / "docs.bson"

        var arguments:[String] = [
            "compile",

            "--package-name", "\(symbol)",
            "--project-type", "\(type)",
            "--workspace", "\(workspace.location)",
            "--output", "\(docs)",
        ]
        if  self.pretty
        {
            arguments.append("--pretty")
        }
        if  let path:String = self.swiftRuntime
        {
            arguments.append("--swift-runtime")
            arguments.append("\(path)")
        }
        if  let path:String = self.swiftPath
        {
            arguments.append("--swift")
            arguments.append("\(path)")
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

        let ssgc:SystemProcess = try .init(command: self.executablePath, arguments: arguments)
        try ssgc()

        let object:SymbolGraphObject<Void> = try .init(buffer: try docs.read())

        try await self.connect { try await $0.upload(object) }
    }
}
