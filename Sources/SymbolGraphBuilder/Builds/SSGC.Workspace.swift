import MarkdownABI
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

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
    var artifacts:FilePath.Directory { self.location / "artifacts" }
    @inlinable public
    var checkouts:FilePath.Directory { self.location / "checkouts" }
}
extension SSGC.Workspace
{
    private
    init(location:FilePath.Directory)
    {
        if  location.path.isAbsolute
        {
            self.init(absolute: location)
        }
        else if
            let current:FilePath.Directory = .current()
        {
            self.init(absolute: .init(path: current.path.appending(location.path.components)))
        }
        else
        {
            fatalError("Couldn’t determine the current working directory.")
        }
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
        try workspace.artifacts.create()
        try workspace.checkouts.create()
        return workspace
    }
}
extension SSGC.Workspace
{
    public
    func build(package build:SSGC.PackageBuild,
        with swift:SSGC.Toolchain,
        clean:Bool = true) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, toolchain: swift, logger: nil, status: nil, clean: clean)
    }

    public
    func build(special build:SSGC.SpecialBuild,
        with swift:SSGC.Toolchain,
        clean:Bool = true) throws -> SymbolGraphObject<Void>
    {
        try self.build(some: build, toolchain: swift, logger: nil, status: nil, clean: clean)
    }
}
extension SSGC.Workspace
{
    func build<Build>(some build:consuming Build,
        toolchain swift:SSGC.Toolchain,
        logger:SSGC.DocumentationLogger?,
        status:SSGC.StatusStream?,
        clean:Bool) throws -> SymbolGraphObject<Void>
        where Build:SSGC.DocumentationBuild
    {
        let metadata:SymbolGraphMetadata
        let package:any SSGC.DocumentationSources

        let artifacts:FilePath.Directory = self.artifacts
        try artifacts.create(clean: clean)

        (metadata, package) = try build.compile(updating: status,
            into: artifacts,
            with: swift)

        let symbols:SSGC.SymbolDumps = try .collect(from: artifacts)
        let index:(any Markdown.SwiftLanguage.IndexStore)?
        do
        {
            index = try package.indexStore(for: swift)
        }
        catch let error
        {
            print("""
                Couldn’t load IndexStoreDB library, advanced syntax highlighting will be \
                disabled! (\(error))
                """)
            index = nil
        }

        let compiled:SymbolGraph = try .compile(
            cultures: package.cultures,
            snippets: package.snippets,
            symbols: symbols,
            prefix: package.prefix,
            logger: logger,
            index: index)

        return .init(metadata: metadata, graph: compiled)
    }
}
