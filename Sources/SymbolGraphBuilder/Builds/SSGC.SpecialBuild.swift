import SymbolGraphs
import System

extension SSGC
{
    public
    struct SpecialBuild
    {
        private
        init()
        {
        }
    }
}
extension SSGC.SpecialBuild
{
    public static
    var swift:Self { .init() }
}
extension SSGC.SpecialBuild:SSGC.DocumentationBuild
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

        try swift.dump(modules: standardLibrary.modules, to: artifacts)
        let sources:SSGC.SpecialSources = .init(modules: standardLibrary.modules)
        return (metadata, sources)
    }
}
