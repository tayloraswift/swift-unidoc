import SymbolGraphs

extension SymbolGraphObject<Void>
{
    public
    init(building build:SSGC.PackageBuild,
        with swift:SSGC.Toolchain,
        pretty:Bool = false) async throws
    {
        try await self.init(some: consume build, with: swift, pretty: pretty)
    }

    public
    init(building build:SSGC.StdlibBuild,
        with swift:SSGC.Toolchain,
        pretty:Bool = false) async throws
    {
        try await self.init(some: consume build, with: swift, pretty: pretty)
    }

    private
    init(some build:consuming some SSGC.DocumentationBuild,
        with swift:SSGC.Toolchain,
        pretty:Bool) async throws
    {
        let metadata:SymbolGraphMetadata
        let package:SSGC.PackageSources

        (metadata, package) = try await build.compile(with: swift)

        let directory:ArtifactsDirectory = { $0.artifacts } (build)
        let artifacts:[Artifacts] = try await swift.dump(modules: package.cultures,
            include: package.include,
            output: directory,
            pretty: pretty)

        let graph:SymbolGraph = try await .build(package: package, from: artifacts)
        self.init(metadata: metadata, graph: graph)
    }
}
