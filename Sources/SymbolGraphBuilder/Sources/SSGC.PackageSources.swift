#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreDB
import class IndexStoreDB.IndexStoreLibrary
import MarkdownPluginSwift_IndexStoreDB

#endif

import MarkdownABI
import SymbolGraphs
import PackageGraphs
import Symbols
import System

extension SSGC
{
    /// Stores information about the source files for a package.
    struct PackageSources
    {
        var cultures:[NominalSources]
        var snippets:[LazyFile]

        let scratch:PackageBuildDirectory
        let root:PackageRoot

        init(
            cultures:[NominalSources] = [],
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
    init(scanning package:borrowing PackageNode,
        scratch:consuming SSGC.PackageBuildDirectory) throws
    {
        self.init(scratch: scratch, root: .init(normalizing: package.root))

        let count:[SSGC.NominalSources.DefaultDirectory: Int] = package.modules.reduce(
            into: [:])
        {
            if  case nil = $1.location,
                let directory:SSGC.NominalSources.DefaultDirectory = .init(for: $1.type)
            {
                $0[directory, default: 0] += 1
            }
        }
        for i:Int in package.modules.indices
        {
            self.cultures.append(try .init(
                exclude: package.exclude[i],
                package: self.root,
                module: package.modules[i],
                count: count))
        }

        guard
        let snippetsDirectory:FilePath.Component = .init(package.snippets)
        else
        {
            throw SSGC.SnippetDirectoryError.invalid(package.snippets)
        }

        let snippets:FilePath = self.root.path.appending(snippetsDirectory)
        if !snippets.directory.exists()
        {
            return
        }

        try snippets.directory.walk
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
    var prefix:Symbol.FileBase? { .init(self.root.path.string) }

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
