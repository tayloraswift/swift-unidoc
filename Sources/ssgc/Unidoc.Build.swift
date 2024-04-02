import SymbolGraphBuilder
import SymbolGraphs
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
        because reason:Unidoc.BuildFailure.Reason,
        logs:consuming Unidoc.BuildLogs) -> Self
    {
        .failure(.init(package: package, failure: .init(reason: reason), logs: logs))
    }

    private static
    func failure(package:Unidoc.Package,
        because reason:Unidoc.BuildFailure.Reason,
        logs:consuming SSGC.PackageBuild.Logs) -> Self
    {
        .failure(
            package: package,
            because: reason,
            logs: .init(
                swiftPackageResolve: logs.swiftPackageResolve.map { .gzip(bytes: $0[...]) },
                swiftPackageBuild: logs.swiftPackageBuild.map { .gzip(bytes: $0[...]) },
                ssgcDocsBuild: nil))
    }
}
extension Unidoc.Build
{
    static
    func with(toolchain:SSGC.Toolchain,
        labels:Unidoc.BuildLabels,
        action:Unidoc.Snapshot.PendingAction) async throws -> Self
    {
        let workspace:SSGC.Workspace = try await .create(at: ".unidoc")

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
                logs: .init())
        }

        guard
        let build:SSGC.PackageBuild = try? await .remote(
            package: labels.package,
            from: labels.repo,
            at: tag,
            in: workspace,
            clean: [.artifacts])
        else
        {
            return .failure(
                package: labels.coordinate.package,
                because: .failedToCloneRepository,
                logs: .init())
        }

        var logs:SSGC.PackageBuild.Logs = .init()

        do
        {
            let archive:SymbolGraphObject<Void> = try await .init(building: build,
                logs: &logs,
                with: toolchain)

            return .success(Unidoc.Snapshot.init(id: labels.coordinate,
                metadata: archive.metadata,
                inline: archive.graph,
                action: action))
        }
        catch let error as SSGC.ManifestDumpError
        {
            return .failure(
                package: labels.coordinate.package,
                because: error.leaf ?
                    .failedToReadManifest :
                    .failedToReadManifestForDependency,
                logs: logs)
        }
        catch let error as SSGC.PackageBuildError
        {
            print("Error: \(error)")

            let reason:Unidoc.BuildFailure.Reason

            switch error
            {
            case .swift_package_update:         reason = .failedToResolveDependencies
            case .swift_build:                  reason = .failedToCompile
            case .swift_symbolgraph_extract:    reason = .failedToCompile
            }

            return .failure(
                package: labels.coordinate.package,
                because: reason,
                logs: logs)
        }
    }
}
