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
        let (namespaces, nominations):([[SSGC.Namespace]], SSGC.Nominations)
        let (extensions):[SSGC.Extension]

        var profiler:BuildProfiler = .init()
        do
        {
            var symbolCache:SSGC.SymbolCache = .init(symbols: symbols)

            for culture:SSGC.NominalSources in cultures
            {
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
                                as: culture.module.language ?? .swift)
                        {
                            $0.loaded.append(dump)
                        }
                        else
                        {
                            $0.missing.append($1)
                        }
                    }
                }

                var graphChecker:SSGC.GraphChecker = .init(root: prefix)

                print(symbols)

                try profiler.measure(\.compiling)
                {
                    try graphChecker.compile(
                        language: culture.module.language ?? .swift,
                        culture: culture.module.id,
                        parts: [])
                }
            }

            (namespaces, nominations) = graphChecker.declarations.load()
            (extensions) = graphChecker.extensions.load()

            print("""
                Compiled documentation!
                    time loading symbols    : \(profiler.loadingSymbols)
                    time compiling          : \(profiler.compiling)
                cultures        : \(namespaces.count)
                namespaces      : \(namespaces.reduce(0) { $0 + $1.count })
                declarations    : \(namespaces.reduce(0)
                {
                    $0 + $1.reduce(0) { $0 + $1.decls.count }
                })
                extensions      : \(extensions.count)
                """)
        }
        catch let error
        {
            throw SSGC.DocumentationBuildError.loading(error)
        }

        do
        {
            var linker:SSGC.Linker = .init(nominations: nominations,
                modules: cultures.map(\.module),
                plugins: [.swift(index: index)],
                root: prefix)

            let namespacePositions:[[SymbolGraph.Namespace]] = profiler.measure(\.linking)
            {
                linker.allocate(namespaces: namespaces)
            }
            let extensionPositions:[(Int32, Int)] = profiler.measure(\.linking)
            {
                linker.allocate(extensions: extensions)
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
                try linker.collate(namespaces: namespaces, at: namespacePositions)
                try linker.collate(extensions: extensions, at: extensionPositions)

                linker.link(
                    namespaces: namespacePositions,
                    extensions: extensionPositions,
                    articles: articles)

                return try linker.load()
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
