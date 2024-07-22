import MarkdownABI
import MarkdownAST
import MarkdownPluginSwift
import Snippets
import SymbolGraphCompiler
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import SourceDiagnostics

extension SymbolGraph
{
    static
    func compile(
        cultures:[SSGC.NominalSources],
        snippets:[SSGC.LazyFile],
        symbols:SSGC.SymbolDumps,
        prefix:Symbol.FileBase?,
        logger:SSGC.DocumentationLogger?,
        index:(any Markdown.SwiftLanguage.IndexStore)? = nil) throws -> Self
    {
        var declarationsCompiled:[SSGC.Declarations] = []
        var extensionsCompiled:[SSGC.Extensions] = []

        var profiler:BuildProfiler = .init()
        do
        {
            var symbolCache:SSGC.SymbolCache = .init(symbols: symbols)

            for culture:SSGC.NominalSources in cultures
            {
                let id:Symbol.Module = culture.module.id
                let symbols:
                (
                    missing:[SymbolGraph.Module],
                    loaded:[SSGC.SymbolDump]
                ) = try profiler.measure(\.loadingSymbols)
                {
                    try culture.dependencies.reduce(into: ([], []))
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

                print("missing modules:", symbols.missing)

                let graphChecker:SSGC.TypeChecker = try profiler.measure(\.compiling)
                {
                    try symbols.loaded.reduce(into: .init())
                    {
                        try $0.add(symbols: $1)
                    }
                }

                declarationsCompiled.append(graphChecker.declarations(in: id,
                    language: culture.module.language ?? .swift))
                extensionsCompiled.append(try graphChecker.extensions(in: id))
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
            var linker:SSGC.Linker = .init(
                plugins: [.swift(index: index)],
                modules: cultures.map(\.module),
                root: prefix)

            profiler.measure(\.linking)
            {
                for declarations:SSGC.Declarations in declarationsCompiled
                {
                    linker.allocate(declarations: declarations)
                }
            }

            let extensionPositions:[[(Int32, Int)]] = profiler.measure(\.linking)
            {
                extensionsCompiled.map{ linker.allocate(extensions: $0) }
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
