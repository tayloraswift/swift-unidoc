import SymbolGraphs
import System_

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
        with toolchain:SSGC.Toolchain,
        clean _:Bool) throws -> (SymbolGraphMetadata, any SSGC.DocumentationSources)
    {
        let standardLibrary:SSGC.StandardLibrary = .init(platform: try toolchain.platform(),
            version: toolchain.splash.swift.version.minor)

        let artifacts:FilePath.Directory = try toolchain.dump(standardLibrary: standardLibrary,
            cache: cache)

        let metadata:SymbolGraphMetadata = .swift(toolchain.splash.swift,
            commit: toolchain.splash.commit,
            triple: toolchain.splash.triple,
            products: standardLibrary.products)

        let sources:SSGC.StandardLibrarySources = .init(modules: standardLibrary.modules,
            symbols: [artifacts])
        return (metadata, sources)
    }
}
