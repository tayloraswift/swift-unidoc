import SymbolGraphs
import SystemIO

extension SSGC {
    public struct StandardLibraryBuild {
        let cache: FilePath.Directory

        public init(cache: FilePath.Directory) {
            self.cache = cache
        }
    }
}
extension SSGC.StandardLibraryBuild: SSGC.DocumentationBuild {
    func compile(
        updating _: SSGC.StatusStream?,
        with toolchain: SSGC.Toolchain,
        clean _: Bool
    ) throws -> (SymbolGraphMetadata, any SSGC.DocumentationSources) {
        let modules: SSGC.ModuleGraph = .stdlib(
            platform: try toolchain.platform(),
            version: toolchain.splash.swift.version.minor
        )

        let artifacts: FilePath.Directory = try toolchain.dump(
            stdlib: modules,
            cache: self.cache
        )

        let metadata: SymbolGraphMetadata = .swift(
            toolchain.splash.swift,
            commit: toolchain.splash.commit,
            triple: toolchain.splash.triple,
            products: .init(viewing: modules.products)
        )

        let sources: SSGC.StandardLibrarySources = .init(modules: modules, symbols: [artifacts])
        return (metadata, sources)
    }
}
