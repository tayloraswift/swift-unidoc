import SymbolGraphs

extension SymbolGraphObject<Void>
{
    public
    init(building build:SPM.Build,
        with swift:Toolchain,
        pretty:Bool = false) async throws
    {
        try await self.init(some: consume build, with: swift, pretty: pretty)
    }

    public
    init(building build:Toolchain.Build,
        with swift:Toolchain,
        pretty:Bool = false) async throws
    {
        try await self.init(some: consume build, with: swift, pretty: pretty)
    }

    private
    init(some build:consuming some DocumentationBuild,
        with swift:Toolchain,
        pretty:Bool) async throws
    {
        let metadata:SymbolGraphMetadata
        let package:SPM.PackageSources

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
