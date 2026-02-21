#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreDB
import class IndexStoreDB.IndexStoreLibrary
import MarkdownPluginSwift_IndexStoreDB

#endif

import MarkdownABI
import MarkdownPluginSwift
import PackageGraphs
import SymbolGraphLinker
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC {
    /// Stores information about the layout, snippets, and build directory for a package.
    @_spi(testable) public struct PackageSources {
        @_spi(testable) public let modules: ModuleGraph
        let symbols: [FilePath.Directory]

        private let scratch: PackageBuildDirectory
        private let root: Symbol.FileBase

        init(
            modules: ModuleGraph,
            symbols: [FilePath.Directory],
            scratch: PackageBuildDirectory,
            root: Symbol.FileBase
        ) {
            self.scratch = scratch
            self.symbols = symbols
            self.modules = modules
            self.root = root
        }
    }
}
extension SSGC.PackageSources: SSGC.DocumentationSources {
    var prefix: Symbol.FileBase? { self.root }

    @_spi(testable) public func indexStore(for swift: SSGC.Toolchain) throws -> (
        any Markdown.SwiftLanguage.IndexStore
    )? {
        #if canImport(IndexStoreDB)

        let libIndexStore: IndexStoreLibrary = try swift.libIndexStore()
        let indexPath: FilePath.Directory = self.scratch.index
        return try IndexStoreDB.init(
            storePath: "\(indexPath)/store",
            databasePath: "\(indexPath)/db",
            library: libIndexStore,
            waitUntilDoneInitializing: true,
            readonly: false,
            listenToUnitEvents: true
        )

        #else

        return nil

        #endif
    }
}
