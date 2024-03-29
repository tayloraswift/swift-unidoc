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
    func build(package:SPM.PackageSources, from artifacts:[Artifacts]) async throws -> Self
    {
        precondition(package.cultures.count == artifacts.count,
            "Mismatched cultures and artifacts!")

        let root:Symbol.FileBase? = (package.root?.path.string).map(Symbol.FileBase.init(_:))

        let (namespaces, nominations):([[SSGC.Namespace]], SSGC.Nominations)
        let (extensions):[SSGC.Extension]

        var profiler:BuildProfiler = .init()
        do
        {
            var checker:SSGC.TypeChecker = .init(root: root)

            for (culture, artifacts):(SPM.NominalSources, Artifacts) in zip(
                package.cultures,
                artifacts)
            {
                let parts:[SymbolGraphPart] = try profiler.measure(\.loadingSymbols)
                {
                    try artifacts.load()
                }

                try profiler.measure(\.compiling)
                {
                    try checker.compile(
                        language: culture.module.language ?? .swift,
                        culture: culture.module.id,
                        parts: parts)
                }
            }

            (namespaces, nominations) = checker.declarations.load()
            (extensions) = checker.extensions.load()

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
            var linker:SSGC.Linker = .init(nominations: nominations,
                modules: package.cultures.map(\.module),
                plugins: [.swift])

            let scalarPositions:[[SymbolGraph.Namespace]] = profiler.measure(\.linking)
            {
                linker.allocate(namespaces: namespaces)
            }
            let extensionPositions:[(Int32, Int)] = profiler.measure(\.linking)
            {
                linker.allocate(extensions: extensions)
            }

            let resources:[[SPM.ResourceFile]] = package.cultures.map(\.resources)
            let markdown:[[SPM.ResourceFile]] = package.cultures.map(\.markdown)
            let snippets:[SPM.ResourceFile] = package.snippets

            let articles:[[SSGC.Article]] = try profiler.measure(\.linking)
            {
                //  Calling this is mandatory, even if there are no supplements!
                try linker.attach(resources: resources,
                    snippets: snippets,
                    markdown: markdown)
            }

            for resource:SPM.ResourceFile in (consume resources).joined()
            {
                profiler.loadingSources += resource.loadingTime
                profiler.linking -= resource.loadingTime
            }
            for markdown:SPM.ResourceFile in (consume markdown).joined()
            {
                profiler.loadingSources += markdown.loadingTime
                profiler.linking -= markdown.loadingTime
            }
            for snippet:SPM.ResourceFile in (consume snippets)
            {
                profiler.loadingSources += snippet.loadingTime
                profiler.linking -= snippet.loadingTime
            }

            let graph:SymbolGraph = try profiler.measure(\.linking)
            {
                try linker.link(articles: articles)

                try linker.link(namespaces: namespaces, at: scalarPositions)
                try linker.link(extensions: extensions, at: extensionPositions)

                return try linker.load()
            }

            linker.status(root: root).emit(colors: .enabled)

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
