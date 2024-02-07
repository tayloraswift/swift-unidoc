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
        let artifacts:Artifacts

        (metadata, artifacts) = try await build.compile(with: swift, pretty: pretty)

        let graph:SymbolGraph = try await .build(from: artifacts)
        self.init(metadata: metadata, graph: graph)
    }
}
