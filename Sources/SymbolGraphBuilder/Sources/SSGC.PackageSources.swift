#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreDB
import class IndexStoreDB.IndexStoreLibrary
import MarkdownPluginSwift_IndexStoreDB
import MarkdownPluginSwift

#endif

import MarkdownABI
import SymbolGraphs
import SymbolGraphLinker
import PackageGraphs
import Symbols
import System

extension SSGC
{
    /// Stores information about the layout, snippets, and build directory for a package.
    @_spi(testable) public
    struct PackageSources
    {
        let cultures:[NominalSources]

        @_spi(testable) public internal(set)
        var snippets:[LazyFile]

        let scratch:PackageBuildDirectory
        let root:PackageRoot

        private
        init(
            cultures:[NominalSources],
            snippets:[LazyFile] = [],
            scratch:PackageBuildDirectory,
            root:PackageRoot)
        {
            self.cultures = cultures
            self.snippets = snippets
            self.scratch = scratch
            self.root = root
        }
    }
}
extension SSGC.PackageSources
{
    private
    init(layout:Layout, scratch:consuming SSGC.PackageBuildDirectory)
    {
        self.init(cultures: layout.cultures, scratch: scratch, root: layout.root)
    }

    init(scanning package:borrowing PackageNode,
        scratch:consuming SSGC.PackageBuildDirectory,
        include:inout [FilePath.Directory]) throws
    {
        self.init(layout: try .init(scanning: package, include: &include), scratch: scratch)

        guard
        let snippetsDirectory:FilePath.Component = .init(package.snippets)
        else
        {
            throw SSGC.SnippetDirectoryError.invalid(package.snippets)
        }

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
                return
            }

            if  file.extension == "swift"
            {
                //  Should we be mangling URL-unsafe characters?
                let snippet:SSGC.LazyFile = .init(location: file.path,
                    path: self.root.rebase(file.path),
                    name: $1.stem)

                self.snippets.append(snippet)
            }
        }
    }
}
extension SSGC.PackageSources:SSGC.DocumentationSources
{
    var prefix:Symbol.FileBase? { .init(self.root.location.path.string) }

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
