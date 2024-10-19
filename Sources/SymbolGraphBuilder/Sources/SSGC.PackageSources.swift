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
import System_

extension SSGC
{
    /// Stores information about the layout, snippets, and build directory for a package.
    @_spi(testable) public
    struct PackageSources
    {
        @_spi(testable) public internal(set)
        var snippets:[LazyFile]

        let scratch:PackageBuildDirectory
        let symbols:[FilePath.Directory]

        private
        let modules:ModuleGraph

        init(
            snippets:[LazyFile] = [],
            scratch:PackageBuildDirectory,
            symbols:[FilePath.Directory],
            modules:ModuleGraph)
        {
            self.snippets = snippets
            self.scratch = scratch
            self.symbols = symbols
            self.modules = modules
        }
    }
}
extension SSGC.PackageSources
{
    private
    var root:SSGC.PackageRoot { self.modules.sinkLayout.root }
}
extension SSGC.PackageSources
{
    mutating
    func detect(snippets snippetsDirectory:FilePath.Component) throws
    {
        let snippets:FilePath.Directory = self.root.location / snippetsDirectory
        if !snippets.exists()
        {
            return
        }

        try snippets.walk
        {
            let file:(path:FilePath, extension:String)

            if  let `extension`:String = $1.extension
            {
                file.extension = `extension`
                file.path = $0 / $1
            }
            else
            {
                //  directory, or some extensionless file we don’t care about
                return true
            }

            if  file.extension == "swift"
            {
                //  Should we be mangling URL-unsafe characters?
                let snippet:SSGC.LazyFile = .init(location: file.path,
                    path: self.root.rebase(file.path),
                    name: $1.stem)

                self.snippets.append(snippet)
                return true
            }
            else
            {
                return true
            }
        }
    }
}
extension SSGC.PackageSources:SSGC.DocumentationSources
{
    var cultures:[SSGC.ModuleLayout] { self.modules.sinkLayout.cultures }
    var prefix:Symbol.FileBase? { .init(self.root.location.path.string) }

    func constituents(of module:__owned SSGC.ModuleLayout) throws -> [SSGC.ModuleLayout]
    {
        try self.modules.constituents(of: module)
    }

    @_spi(testable) public
    func indexStore(for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    {
        #if canImport(IndexStoreDB)

        let libIndexStore:IndexStoreLibrary = try swift.libIndexStore()
        let indexPath:FilePath = self.scratch.include / "index"
        return try IndexStoreDB.init(storePath: "\(indexPath)/store",
            databasePath: "\(indexPath)/db",
            library: libIndexStore,
            waitUntilDoneInitializing: true,
            readonly: false,
            listenToUnitEvents: true)

        #else

        return nil

        #endif
    }
}
