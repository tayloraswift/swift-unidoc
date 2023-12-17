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

        let clock:ContinuousClock = .init()
        var time:(compiling:Duration, linking:Duration)

        do
        {
            time.compiling = .zero

            var compiler:Compiler = .init(root: artifacts.root)

            for culture:Artifacts.Culture in artifacts.cultures
            {
                let parts:[SymbolGraphPart] = try culture.loadSymbols()

                time.compiling += try clock.measure
                {
                    try compiler.compile(culture: culture.id, parts: parts)
                }
            }

            (namespaces, nominations) = compiler.declarations.load()
            (extensions) = compiler.extensions.load()

            print("""
                Compiled documentation in \(time.compiling)
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
            let supplements:[[MarkdownSourceFile]]? = try artifacts.root.map
            {
                (root:Symbol.FileBase) in try artifacts.cultures.map
                {
                    switch $0.module.type
                    {
                    //  Only load supplements for these module types.
                    case .executable:   break
                    case .regular:      break
                    case .macro:        break
                    case .plugin:       break
                    default:            return []
                    }

                    return try $0.loadArticles(root: root)
                }
            }

            var linker:StaticLinker = .init(nominations: nominations,
                modules: artifacts.cultures.map(\.module),
                plugins: [.swift])

            time.linking = clock.measure
            {
                let scalarPositions:[[SymbolGraph.Namespace]] = linker.allocate(
                    namespaces: namespaces)
                let extensionPositions:[(Int32, Int)] = linker.allocate(
                    extensions: extensions)

                //  Calling this is mandatory, even if there are no supplements.
                linker.attach(supplements: supplements ?? [])

                linker.link(namespaces: namespaces, at: scalarPositions)
                linker.link(extensions: extensions, at: extensionPositions)
            }

            let graph:SymbolGraph = try linker.load()

            linker.status(root: artifacts.root).emit(colors: .enabled)

            print("""
                Linked documentation in \(time.linking)
                symbols         : \(graph.decls.symbols.count)
                """)

            return graph
        }
    }
}
