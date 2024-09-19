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
import System_

extension SSGC
{
    protocol DocumentationSources
    {
        var symbols:[FilePath.Directory] { get }

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
    func link(logger:SSGC.Logger, with swift:SSGC.Toolchain) throws -> SymbolGraph
    {
        let moduleLayouts:[SSGC.ModuleLayout] = self.cultures
        let snippets:[SSGC.LazyFile] = self.snippets
        let prefix:Symbol.FileBase? = self.prefix

        let moduleIndexes:[SSGC.ModuleIndex]

        var profiler:SSGC.DocumentationBuildProfiler = .init()
        do
        {
            var symbolCache:SSGC.SymbolCache = .init(symbols: try .collect(from: self.symbols))

            moduleIndexes = try moduleLayouts.map
            {
                let id:Symbol.Module = $0.id
                let constituents:[SSGC.ModuleLayout] = try self.constituents(of: $0).filter(
                    \.module.type.hasSymbols)

                let symbols:
                (
                    missing:[SSGC.ModuleLayout],
                    loaded:[SSGC.SymbolCulture]
                ) = try profiler.measure(\.loadingSymbols)
                {
                    let selection:Set<Symbol.Module> = constituents.reduce(into: [])
                    {
                        $0.insert($1.id)
                    }

                    return try constituents.reduce(into: ([], []))
                    {
                        if  let module:SSGC.SymbolCulture = try symbolCache.load(module: $1.id,
                                filter: selection,
                                base: prefix,
                                as: $1.language ?? .swift)
                        {
                            $0.loaded.append(module)
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

                var module:SSGC.ModuleIndex = try compiler.load(in: id)

                module.resources = $0.resources
                module.markdown = $0.markdown
                module.language = $0.language

                return module
            }

            print("""
                Compiled documentation!
                    time loading symbols    : \(profiler.loadingSymbols)
                    time compiling          : \(profiler.compiling)
                cultures        : \(cultures.count)
                namespaces      : \(moduleIndexes.reduce(0) { $0 + $1.declarations.count })
                declarations    : \(moduleIndexes.reduce(0)
                {
                    $0 + $1.declarations.reduce(0) { $0 + $1.decls.count }
                })
                extensions      : \(moduleIndexes.reduce(0) { $0 + $1.extensions.count })
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

            let graph:SymbolGraph = try profiler.measure(\.linking)
            {
                try .link(projectRoot: prefix,
                    plugins: [.swift(index: index)],
                    modules: moduleLayouts.map(\.module),
                    indexes: moduleIndexes,
                    snippets: snippets,
                    logger: logger)
            }

            for resource:SSGC.LazyFile in moduleLayouts.lazy.map(\.resources).joined()
            {
                profiler.loadingSources += resource.loadingTime
                profiler.linking -= resource.loadingTime
            }
            for markdown:SSGC.LazyFile in moduleLayouts.lazy.map(\.markdown).joined()
            {
                profiler.loadingSources += markdown.loadingTime
                profiler.linking -= markdown.loadingTime
            }
            for snippet:SSGC.LazyFile in snippets
            {
                profiler.loadingSources += snippet.loadingTime
                profiler.linking -= snippet.loadingTime
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
