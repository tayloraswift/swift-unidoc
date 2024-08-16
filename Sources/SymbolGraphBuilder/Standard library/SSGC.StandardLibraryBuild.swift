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
        cache:FilePath.Directory,
        with swift:SSGC.Toolchain,
        clean _:Bool) throws -> (SymbolGraphMetadata, any SSGC.DocumentationSources)
    {
        let standardLibrary:SSGC.StandardLibrary = .init(platform: try swift.platform())

        let artifacts:FilePath.Directory = try swift.dump(standardLibrary: standardLibrary,
            options: .default,
            cache: cache)

        let metadata:SymbolGraphMetadata = .swift(swift.id,
            commit: swift.commit,
            triple: swift.triple,
            products: standardLibrary.products)

        let sources:SSGC.StandardLibrarySources = .init(modules: standardLibrary.modules,
            symbols: [artifacts])
        return (metadata, sources)
    }
}
