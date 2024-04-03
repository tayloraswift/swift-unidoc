import SymbolGraphs
import System

extension SymbolGraphObject<Void>
{
    public
    init(building build:SSGC.PackageBuild,
        with swift:SSGC.Toolchain) async throws
    {
        var logs:SSGC.PackageBuild.Logs = .init()
        try await self.init(some: consume build, logs: &logs, with: swift)
    }
    public
    init(building build:SSGC.PackageBuild,
        logs:inout SSGC.PackageBuild.Logs,
        with swift:SSGC.Toolchain) async throws
    {
        try await self.init(some: consume build, logs: &logs, with: swift)
    }
}
extension SymbolGraphObject<Void>
{
    public
    init(building build:SSGC.StdlibBuild,
        with swift:SSGC.Toolchain) async throws
    {
        var logs:SSGC.StdlibBuild.Logs = .init()
        try await self.init(some: consume build, logs: &logs, with: swift)
    }
    public
    init(building build:SSGC.StdlibBuild,
        logs:inout SSGC.StdlibBuild.Logs,
        with swift:SSGC.Toolchain) async throws
    {
        try await self.init(some: consume build, logs: &logs, with: swift)
    }
}
extension SymbolGraphObject<Void>
{
    private
    init<Build>(some build:consuming Build,
        logs:inout Build.Logs,
        with swift:SSGC.Toolchain) async throws where Build:SSGC.DocumentationBuild
    {
        let metadata:SymbolGraphMetadata
        let package:SSGC.PackageSources

        (metadata, package) = try await build.compile(with: swift, logs: &logs)

        let directory:ArtifactsDirectory = build.artifacts
        let extractor:FilePath = directory.path / "extractor.log"
        defer
        {
            if  let extractor:[UInt8] = try? extractor.read()
            {
                logs.attach(extractorLog: extractor)
            }
        }

        let artifacts:[Artifacts] = try await swift.dump(modules: package.cultures,
            include: package.include,
            output: directory,
            log: extractor)

        let graph:SymbolGraph = try await .build(package: package,
            from: artifacts,
            logs: &logs)

        self.init(metadata: metadata, graph: graph)
    }
}
