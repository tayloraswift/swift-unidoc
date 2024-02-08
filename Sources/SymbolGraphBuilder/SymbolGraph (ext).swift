import MarkdownABI
import MarkdownAST
import MarkdownPluginSwift
import SymbolGraphCompiler
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import UnidocDiagnostics

extension SymbolGraph
{
    static
    func build(from artifacts:Artifacts) async throws -> Self
    {
        let (namespaces, nominations):([[Compiler.Namespace]], Compiler.Nominations)
        let (extensions):[Compiler.Extension]

        var profiler:BuildProfiler = .init()
        do
        {
            var compiler:Compiler = .init(root: artifacts.root)

            for culture:Artifacts.Culture in artifacts.cultures
            {
                let parts:[SymbolGraphPart] = try profiler.measure(\.loadingSymbols)
                {
                    try culture.loadSymbols()
                }

                try profiler.measure(\.compiling)
                {
                    try compiler.compile(
                        language: culture.module.language ?? .swift,
                        culture: culture.id,
                        parts: parts)
                }
            }

            (namespaces, nominations) = compiler.declarations.load()
            (extensions) = compiler.extensions.load()

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
        do
        {
            var linker:StaticLinker = .init(nominations: nominations,
                modules: artifacts.cultures.map(\.module),
                plugins: [.swift])

            let scalarPositions:[[SymbolGraph.Namespace]] = profiler.measure(\.linking)
            {
                linker.allocate(namespaces: namespaces)
            }
            let extensionPositions:[(Int32, Int)] = profiler.measure(\.linking)
            {
                linker.allocate(extensions: extensions)
            }

            //  Load and attach snippets.
            let snippets:[SnippetSourceFile] = try profiler.measure(\.loadingSources)
            {
                try artifacts.loadSnippets()
            }

            profiler.measure(\.linking)
            {
                linker.attach(snippets: snippets)
            }

            _ = consume snippets

            //  Load and attach markdown supplements.
            let markdown:[[MarkdownSourceFile]] = try profiler.measure(\.loadingSources)
            {
                try artifacts.loadMarkdown()
            }

            let graph:SymbolGraph = try profiler.measure(\.linking)
            {
                //  Calling this is mandatory, even if there are no supplements!
                linker.attach(markdown: markdown)

                linker.link(namespaces: namespaces, at: scalarPositions)
                linker.link(extensions: extensions, at: extensionPositions)

                return try linker.load()
            }

            _ = consume markdown

            linker.status(root: artifacts.root).emit(colors: .enabled)

            print("""
                Linked documentation!
                    time loading sources    : \(profiler.loadingSources)
                    time linking            : \(profiler.linking)
                symbols         : \(graph.decls.symbols.count)
                """)

            return graph
        }
    }
}
