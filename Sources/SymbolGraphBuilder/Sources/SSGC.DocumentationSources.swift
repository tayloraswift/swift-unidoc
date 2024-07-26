import MarkdownABI
import MarkdownAST
import MarkdownPluginSwift
import Snippets
import SourceDiagnostics
import SymbolGraphCompiler
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    protocol DocumentationSources
    {
        var cultures:[ModuleLayout] { get }
        var snippets:[LazyFile] { get }

        var prefix:Symbol.FileBase? { get }

        /// Returns all constituents of the given module (including transitive dependencies),
        /// sorted in topological dependency order. The list ends with the given module.
        func constituents(of culture:__owned ModuleLayout) throws -> [ModuleLayout]

        func indexStore(
            for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    }
}
extension SSGC.DocumentationSources
{
    func link(symbols:SSGC.SymbolDumps,
        logger:SSGC.DocumentationLogger?,
        with swift:SSGC.Toolchain) throws -> SymbolGraph
    {
        let cultures:[SSGC.ModuleLayout] = self.cultures
        let snippets:[SSGC.LazyFile] = self.snippets
        let prefix:Symbol.FileBase? = self.prefix

        var declarationsCompiled:[SSGC.Declarations] = []
        var extensionsCompiled:[SSGC.Extensions] = []

        var profiler:SSGC.DocumentationBuildProfiler = .init()
        do
        {
            var symbolCache:SSGC.SymbolCache = .init(symbols: symbols)

            for module:SSGC.ModuleLayout in cultures
            {
                let id:Symbol.Module = module.id
                let symbols:
                (
                    missing:[SSGC.ModuleLayout],
                    loaded:[SSGC.SymbolDump]
                ) = try profiler.measure(\.loadingSymbols)
                {
                    let constituents:[SSGC.ModuleLayout] = try self.constituents(of: module)
                    return try constituents.reduce(into: ([], []))
                    {
                        if  let dump:SSGC.SymbolDump = try symbolCache.load(module: $1.id,
                                base: prefix,
                                as: $1.language ?? .swift)
                        {
                            $0.loaded.append(dump)
                        }
                        else
                        {
                            $0.missing.append($1)
                        }
                    }
                }

                print("Compiling documentation for \(id)...")

                if !symbols.missing.isEmpty
                {
                    print("WARNING: \(symbols.missing.count) modules failed to dump symbols")
                    for module:SSGC.ModuleLayout in symbols.missing
                    {
                        print("  - \(module.id) (\(module.language ?? .swift))")
                    }
                }

                let compiler:SSGC.TypeChecker = try profiler.measure(\.compiling)
                {
                    try symbols.loaded.reduce(into: .init())
                    {
                        try $0.add(symbols: $1)
                    }
                }

                let language:Phylum.Language = module.language ?? .swift

                declarationsCompiled.append(compiler.declarations(in: id, language: language))
                extensionsCompiled.append(try compiler.extensions(in: id))
            }

            print("""
                Compiled documentation!
                    time loading symbols    : \(profiler.loadingSymbols)
                    time compiling          : \(profiler.compiling)
                cultures        : \(cultures.count)
                namespaces      : \(declarationsCompiled.reduce(0) { $0 + $1.namespaces.count })
                declarations    : \(declarationsCompiled.reduce(0)
                {
                    $0 + $1.namespaces.reduce(0) { $0 + $1.decls.count }
                })
                extensions      : \(extensionsCompiled.reduce(0) { $0 + $1.compiled.count })
                """)
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.loading(error)
        }

        do
        {
            let index:(any Markdown.SwiftLanguage.IndexStore)?
            do
            {
                index = try self.indexStore(for: swift)
            }
            catch let error
            {
                print("""
                    Couldn’t load IndexStoreDB library, advanced syntax highlighting will be \
                    disabled! (\(error))
                    """)
                index = nil
            }

            var linker:SSGC.Linker = profiler.measure(\.linking)
            {
                .init(
                    plugins: [.swift(index: index)],
                    modules: cultures.map(\.module),
                    allocating: declarationsCompiled,
                    extensions: extensionsCompiled,
                    root: prefix)
            }

            let extensionPositions:[[(Int32, Int)]] = profiler.measure(\.linking)
            {
                extensionsCompiled.map{ linker.unfurl(extensions: $0) }
            }

            let resources:[[SSGC.LazyFile]] = cultures.map(\.resources)
            let markdown:[[SSGC.LazyFile]] = cultures.map(\.markdown)
            let snippets:[SSGC.LazyFile] = snippets

            let articles:[[SSGC.Article]] = try profiler.measure(\.linking)
            {
                //  Calling this is mandatory, even if there are no supplements!
                try linker.attach(resources: resources,
                    snippets: snippets,
                    markdown: markdown)
            }

            for resource:SSGC.LazyFile in (consume resources).joined()
            {
                profiler.loadingSources += resource.loadingTime
                profiler.linking -= resource.loadingTime
            }
            for markdown:SSGC.LazyFile in (consume markdown).joined()
            {
                profiler.loadingSources += markdown.loadingTime
                profiler.linking -= markdown.loadingTime
            }
            for snippet:SSGC.LazyFile in (consume snippets)
            {
                profiler.loadingSources += snippet.loadingTime
                profiler.linking -= snippet.loadingTime
            }

            let graph:SymbolGraph = try profiler.measure(\.linking)
            {
                for declarations:SSGC.Declarations in declarationsCompiled
                {
                    try linker.collate(declarations: declarations)
                }
                for (extensions, extensionPositions):(SSGC.Extensions, [(Int32, Int)]) in zip(
                    extensionsCompiled,
                    extensionPositions)
                {
                    try linker.collate(extensions: extensions.compiled, at: extensionPositions)
                }

                return try linker.link(extensions: extensionPositions, articles: articles)
            }

            if  let logger:SSGC.DocumentationLogger
            {
                try logger.emit(messages: linker.status())
            }
            else
            {
                linker.status().emit(colors: .enabled)
            }

            print("""
                Linked documentation!
                    time loading sources    : \(profiler.loadingSources)
                    time linking            : \(profiler.linking)
                symbols         : \(graph.decls.symbols.count)
                """)

            return graph
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.linking(error)
        }
    }
}
