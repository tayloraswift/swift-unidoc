import MarkdownABI
import SymbolGraphParts
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC
{
    @frozen public
    struct Workspace:Equatable
    {
        public
        let location:FilePath.Directory

        private
        init(absolute location:FilePath.Directory)
        {
            self.location = location
        }
    }
}
extension SSGC.Workspace
{
    @inlinable public
    var cache:FilePath.Directory { self.location / "cache" }
    @inlinable public
    var checkouts:FilePath.Directory { self.location / "checkouts" }
}
extension SSGC.Workspace
{
    private
    init(location:FilePath.Directory)
    {
        self.init(absolute: location.absolute())
    }

    public static
    func existing(at location:FilePath.Directory) -> Self
    {
        .init(location: location)
    }

    public static
    func create(at location:FilePath.Directory) throws -> Self
    {
        let workspace:Self = .init(location: location)
        try workspace.cache.create()
        try workspace.checkouts.create()
        return workspace
    }
}
extension SSGC.Workspace
{
    public
    func build(package build:SSGC.PackageBuild,
        with swift:SSGC.Toolchain,
        validation:SSGC.ValidationBehavior = .ignoreErrors,
        clean:Bool = true) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build,
            toolchain: swift,
            logger: .init(validation: validation, file: nil),
            clean: clean)
    }

    public
    func build(special build:SSGC.StandardLibraryBuild,
        with swift:SSGC.Toolchain,
        validation:SSGC.ValidationBehavior = .ignoreErrors,
        clean:Bool = true) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build,
            toolchain: swift,
            logger: .init(validation: validation, file: nil),
            clean: clean)
    }
}
extension SSGC.Workspace
{
    func build<Build>(some build:consuming Build,
        toolchain swift:SSGC.Toolchain,
        define defines:[String] = [],
        status:SSGC.StatusStream? = nil,
        logger:SSGC.Logger = .default(),
        clean:Bool) throws -> SymbolGraphObject<Void>
        where Build:SSGC.DocumentationBuild
    {
        /// TODO: support values?
        let definitions:[String: Void] = defines.reduce(into: [:]) { $0[$1] = () }

        let metadata:SymbolGraphMetadata
        let package:any SSGC.DocumentationSources

        let cache:FilePath.Directory = self.cache
        try cache.create(clean: clean)

        (metadata, package) = try build.compile(updating: status,
            cache: cache,
            with: swift,
            clean: clean)

        let documentation:SymbolGraph = try package.link(
            definitions: definitions,
            logger: logger,
            with: swift)

        return .init(metadata: metadata, graph: documentation)
    }
}
