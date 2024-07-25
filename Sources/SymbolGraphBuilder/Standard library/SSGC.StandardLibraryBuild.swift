import SymbolGraphs
import System

extension SSGC
{
    public
    struct StandardLibraryBuild
    {
        private
        init()
        {
        }
    }
}
extension SSGC.StandardLibraryBuild
{
    public static
    var swift:Self { .init() }
}
extension SSGC.StandardLibraryBuild:SSGC.DocumentationBuild
{
    func compile(updating _:SSGC.StatusStream?,
        into artifacts:FilePath.Directory,
        with swift:SSGC.Toolchain) throws -> (SymbolGraphMetadata,
        any SSGC.DocumentationSources)
    {
        let standardLibrary:SSGC.StandardLibrary = .init(platform: try swift.platform())

        let metadata:SymbolGraphMetadata = .swift(swift.version,
            commit: swift.commit,
            triple: swift.triple,
            products: standardLibrary.products)

        for module:SymbolGraph.Module in standardLibrary.modules
        {
            try swift.dump(module: module.id, to: artifacts)
        }

        let sources:SSGC.StandardLibrarySources = .init(modules: standardLibrary.modules)
        return (metadata, sources)
    }
}
