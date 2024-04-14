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
        with swift:SSGC.Toolchain) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, toolchain: swift, logger: nil, status: nil)
    }

    public
    func build(special build:SSGC.SpecialBuild,
        with swift:SSGC.Toolchain) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, toolchain: swift, logger: nil, status: nil)
    }
}
extension SSGC.Workspace
{
    func build<Build>(some build:consuming Build,
        toolchain swift:SSGC.Toolchain,
        logger:SSGC.DocumentationLogger?,
        status:SSGC.StatusStream?) throws -> SymbolGraphObject<Void>
        where Build:SSGC.DocumentationBuild
    {
        let metadata:SymbolGraphMetadata
        let package:SSGC.PackageSources

        let output:FilePath = self.artifacts
        try output.directory.create(clean: true)

        (metadata, package) = try build.compile(updating: status, into: output, with: swift)

        let artifacts:[Artifacts] = try swift.dump(modules: package.cultures,
            include: package.include,
            output: output)

        let compiled:SymbolGraph = try .compile(artifacts: artifacts,
            package: package,
            logger: logger)

        return .init(metadata: metadata, graph: compiled)
    }
}
