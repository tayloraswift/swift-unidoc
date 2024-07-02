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
    @frozen public
    struct Client<Protocol>:Sendable where Protocol:HTTP.Client
    {
        public
        let executablePath:String?

        public
        let swiftRuntime:String?
        public
        let swiftPath:String?
        public
        let swiftSDK:SSGC.AppleSDK?
        public
        let pretty:Bool
        public
        let authorization:String?

        public
        let http:Protocol
        public
        let port:Int

        @inlinable public
        init(
            swiftRuntime:String?,
            swiftPath:String?,
            swiftSDK:SSGC.AppleSDK?,
            pretty:Bool,
            authorization:String?,
            http:Protocol,
            port:Int)
        {
            //  On macOS, `/proc/self/exe` is not available, so we must fall back to using the
            //  path supplied by `argv[0]`.
            //
            //  FIXME: according to Alastair Houghton, we should be using `_NSGetExecutablePath`
            //  https://swift-open-source.slack.com/archives/C5FAE2LL9/p1714118940393719?thread_ts=1714079460.781409&cid=C5FAE2LL9

            #if os(macOS)
            self.executablePath = CommandLine.arguments.first
            #else
            self.executablePath = nil
            #endif

            self.swiftRuntime = swiftRuntime
            self.swiftPath = swiftPath
            self.swiftSDK = swiftSDK
            self.pretty = pretty
            self.authorization = authorization
            self.http = http
            self.port = port
        }
    }
}
extension Unidoc.Client
{
    @inlinable public
    func connect<T>(with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http.connect(port: self.port)
        {
            try await body(.init(http: $0, authorization: self.authorization))
        }
    }
}
extension Unidoc.Client<HTTP.Client2>
{
    /// Listens for SSGC updates over the provided pipe, uploading any intermediate reports to
    /// Unidoc server and returning the final report, without uploading it.
    private
    func stream(from pipe:FilePath, package:Unidoc.Package) async throws -> Unidoc.BuildFailure?
    {
        try await SSGC.StatusStream.read(from: pipe)
        {
            //  Acknowledge the build request.
            try? await self.connect
            {
                try await $0.upload(.init(package: package, entered: .cloningRepository))
            }

            while let update:SSGC.StatusUpdate = try $0.next()
            {
                let stage:Unidoc.BuildStage

                switch update
                {
                case .didCloneRepository:
                    stage = .resolvingDependencies

                case .didResolveDependencies:
                    stage = .compilingCode

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

                try await self.connect
                {
                    try await $0.upload(.init(package: package, entered: stage))
                }
            }

            return nil
        }
    }

    @discardableResult public
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

        let started:ContinuousClock.Instant = .now
        let type:SSGC.ProjectType = labels.book ? .book : .package

        /// Temporarily open the named pipe for the express purpose of duping it into the child
        /// process.
        ///
        /// Even though it would never make sense to read from this file descriptor - either
        /// from within this block, or from the child process, we open the pipe for both reading
        /// and writing so that it is considered active for the lifetime of the child process.
        /// This allows the child process to write to the pipe without synchronizing with the
        /// parent process.
        let childProcess:SystemProcess = try status.open(.readWrite, permissions: (.rw, .r, .r))
        {
            (pipe:FileDescriptor) in

            try output.open(.writeOnly,
                permissions: (.rw, .r, .r),
                options: [.create, .truncate])
            {
                var arguments:[String] = [
                    "compile",

                    "--package-name", "\(labels.package)",
                    "--project-type", "\(type)",
                    "--project-repo", labels.repo,
                    "--ref", labels.ref,
                    "--workspace", "\(workspace.location)",
                    "--status", "3",
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

                return try .init(command: self.executablePath,
                    arguments: arguments,
                    stdout: $0,
                    stderr: $0,
                    duping: [3 <- pipe])
            }
        }

        let failure:Unidoc.BuildFailure? = try await self.stream(from: status,
            package: labels.coordinate.package)

        var artifact:Unidoc.BuildArtifact = .init(package: labels.coordinate.package,
            outcome: .failure(failure ?? .failedForUnknownReason))

        //  Check the exit status of the child process.
        if  case nil = failure,
            case .success = childProcess.status()
        {
            let object:SymbolGraphObject<Void> = try .init(buffer: try docs.read())

            artifact.outcome = .success(.init(id: labels.coordinate,
                metadata: object.metadata,
                inline: object.graph,
                action: action))
        }

        /// Attach build logs.
        try artifact.attach(log: output, as: .ssgc)
        try artifact.attach(log: diagnostics, as: .ssgcDiagnostics)

        artifact.seconds = (.now - started).components.seconds

        try await self.connect
        {
            try await $0.upload(artifact)
        }

        if  case .failure = artifact.outcome
        {
            return false
        }
        else
        {
            return true
        }
    }

    public
    func buildAndUpload(local symbol:Symbol.Package,
        search:FilePath?,
        type:SSGC.ProjectType) async throws
    {
        let object:SymbolGraphObject<Void> = try await self.build(local: symbol,
            search: search,
            type: type)

        try await self.connect { try await $0.upload(object) }

        print("""
            View the generated documentation at:
            https://\(self.http.remote):\(self.port)/tags/\(symbol)
            """)
    }
}
extension Unidoc.Client<HTTP.Client1>
{
    public
    func buildAndUpload(local symbol:Symbol.Package,
        search:FilePath?,
        type:SSGC.ProjectType) async throws
    {
        let object:SymbolGraphObject<Void> = try await self.build(local: symbol,
            search: search,
            type: type)

        try await self.connect { try await $0.upload(object) }

        print("""
            View the generated documentation at:
            http://\(self.http.remote):\(self.port)/tags/\(symbol)
            """)
    }
}
extension Unidoc.Client
{
    private
    func build(local symbol:Symbol.Package,
        search:FilePath?,
        type:SSGC.ProjectType) async throws -> SymbolGraphObject<Void>
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

        return try .init(buffer: try docs.read())
    }
}
