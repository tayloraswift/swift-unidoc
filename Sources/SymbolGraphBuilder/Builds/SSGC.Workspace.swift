import SymbolGraphs
import System

extension SSGC
{
    @frozen public
    struct Workspace:Equatable
    {
        public
        let path:FilePath

        private
        init(path:FilePath)
        {
            self.path = path
        }
    }
}
extension SSGC.Workspace
{
    @inlinable public
    var artifacts:FilePath { self.path / "artifacts" }
    @inlinable public
    var checkouts:FilePath { self.path / "checkouts" }
    @inlinable public
    var status:FilePath { self.path / "status" }
}
extension SSGC.Workspace
{
    public static
    func existing(at location:FilePath) -> Self
    {
        .init(path: location)
    }

    public static
    func create(at location:FilePath) throws -> Self
    {
        let workspace:Self = .init(path: location)
        try workspace.artifacts.directory.create()
        try workspace.checkouts.directory.create()
        return workspace
    }
}
extension SSGC.Workspace
{
    public
    func build(package build:SSGC.PackageBuild,
        with swift:SSGC.Toolchain,
        log:FilePath.Component? = nil) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, with: swift, log: log)
    }

    public
    func build(special build:SSGC.SpecialBuild,
        with swift:SSGC.Toolchain,
        log:FilePath.Component? = nil) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, with: swift, log: log)
    }
}
extension SSGC.Workspace
{
    private
    func build<Build>(some build:consuming Build,
        with swift:SSGC.Toolchain,
        log:FilePath.Component?) throws -> SymbolGraphObject<Void>
        where Build:SSGC.DocumentationBuild
    {
        let metadata:SymbolGraphMetadata
        let package:SSGC.PackageSources

        let output:FilePath = self.artifacts
        try output.directory.create(clean: true)

        (metadata, package) = try build.compile(into: output, with: swift)

        let artifacts:[Artifacts] = try swift.dump(modules: package.cultures,
            include: package.include,
            output: output)

        let graph:SymbolGraph = try .build(package: package,
            from: artifacts,
            log: log.map { .init(path: output / $0) })

        return .init(metadata: metadata, graph: graph)
    }
}
