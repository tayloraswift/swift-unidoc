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
    init(location:FilePath.Directory)
    {
        self.init(absolute: location.absolute())
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
    func build(package:SSGC.PackageBuild,
        with swift:SSGC.Toolchain,
        validation:SSGC.ValidationBehavior = .ignoreErrors,
        clean:Bool = true) throws -> SymbolGraphObject<Void>
    {
        try package.build(
            toolchain: swift,
            logger: .init(validation: validation, file: nil),
            clean: clean)
    }

    public
    func buildStandardLibrary(
        with swift:SSGC.Toolchain,
        validation:SSGC.ValidationBehavior = .ignoreErrors,
        clean:Bool = true) throws -> SymbolGraphObject<Void>
    {
        let stdlib:SSGC.StandardLibraryBuild = .init(cache: self.cache)
        try stdlib.cache.create(clean: clean)
        return try stdlib.build(
            toolchain: swift,
            logger: .init(validation: validation, file: nil),
            clean: clean)
    }
}
