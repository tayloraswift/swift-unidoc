import SymbolGraphBuilder
import SymbolGraphs
import System
import UnidocRecords_LZ77

extension Unidoc
{
    /// This is a ``Result``oid we use as an code-organization tool.
    enum Build
    {
        case success(Unidoc.Snapshot)
        case failure(Unidoc.BuildFailureReport)
    }
}
extension Unidoc.Build
{
    private static
    func failure(package:Unidoc.Package,
        because failure:Unidoc.BuildFailure.Reason,
        logs:consuming [Unidoc.BuildLog]) -> Self
    {
        .failure(.init(package: package, failure: .init(reason: failure), logs: logs))
    }
}
extension Unidoc.Build
{
    static
    func with(toolchain:SSGC.Toolchain,
        labels:Unidoc.BuildLabels,
        action:Unidoc.Snapshot.PendingAction) async throws -> Self
    {
        guard
        let tag:String = labels.tag
        else
        {
            print("""
                No new documentation to build, run with -f or -e to build the latest release
                or prerelease anyway.
                """)

            return .failure(
                package: labels.coordinate.package,
                because: .noValidVersion,
                logs: [])
        }

        let workspace:SSGC.Workspace = try .create(at: ".unidoc")
        let output:FilePath = workspace.path / "output"
        let pipe:FilePath = workspace.path / "status"

        try SystemProcess.init(command: "rm", "-f", "\(pipe)")()
        try SystemProcess.init(command: "mkfifo", "\(pipe)")()

        let ssgc:SystemProcess = try output.open(.writeOnly,
            permissions: (.rw, .r, .r),
            options: [.create, .truncate])
        {
            try .init(command: nil, "build",
                "--package-name", "\(labels.package)",
                "--package-repo", labels.repo,
                "--tag", tag,
                "--workspace", "\(workspace.path)",
                "--status", "\(pipe)",
                "--log-to-file",
                stdout: $0,
                stderr: $0)
        }

        async
        let status:SSGC.StatusUpdate? =
        {
            //  Unblock the child process.
            try $0.open(.readOnly) { try $0.readByte(as: SSGC.StatusUpdate.self) }
        } (pipe)

        //  Wait for the child process to finish.
        try ssgc()

        guard
        let status:SSGC.StatusUpdate = try await status
        else
        {
            fatalError("SSGC exited successfully without writing a status update!")
        }

        let failure:Unidoc.BuildFailure.Reason

        switch status
        {
        case .success:
            let object:SymbolGraphObject<Void> = try .init(
                buffer: try (workspace.artifacts / "docs.bson").read())

            return .success(Unidoc.Snapshot.init(id: labels.coordinate,
                metadata: object.metadata,
                inline: object.graph,
                action: action))

        case .failedToCloneRepository:
            failure = .failedToCloneRepository

        case .failedToReadManifest:
            failure = .failedToReadManifest

        case .failedToReadManifestForDependency:
            failure = .failedToReadManifestForDependency

        case .failedToResolveDependencies:
            failure = .failedToResolveDependencies

        case .failedToBuild:
            failure = .failedToBuild

        case .failedToExtractSymbolGraph:
            failure = .failedToExtractSymbolGraph

        case .failedToLoadSymbolGraph:
            failure = .failedToLoadSymbolGraph

        case .failedToLinkSymbolGraph:
            failure = .failedToLinkSymbolGraph
        }

        let ssgcLog:[UInt8] = try output.read()
        if  ssgcLog.isEmpty
        {
            return .failure(package: labels.coordinate.package, because: failure, logs: [])
        }
        else
        {
            return .failure(package: labels.coordinate.package, because: failure, logs: [
                .init(text: .gzip(bytes: ssgcLog[...], level: 10), type: .swiftPackageBuild)
            ])
        }
    }
}
