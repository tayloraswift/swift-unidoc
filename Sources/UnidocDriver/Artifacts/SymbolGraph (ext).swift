import ModuleGraphs
import SymbolGraphs
import SymbolGraphParts
import UnidocCompiler
import UnidocLinker

extension SymbolGraph
{
    public static
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

            (namespaces, nominations) = compiler.scalars.load()
            (extensions) = compiler.extensions.load()

            print("""
                Compiled documentation in \(time.compiling) \
                (\(namespaces.count) culture(s), containing \
                \(namespaces.reduce(0) { $0 + $1.count }) namespace(s),
                \(namespaces.reduce(0) { $0 + $1.reduce(0) { $0 + $1.scalars.count } }) \
                declaration(s), and \(extensions.count) extension(s))
                """)
        }
        do
        {
            var linker:StaticLinker = .init(nominations: nominations,
                modules: artifacts.cultures.map(\.module))

            let supplements:[[MarkdownFile]]? = try artifacts.root.map
            {
                (root:Repository.Root) in try artifacts.cultures.map
                {
                    try $0.loadArticles(root: root)
                }
            }

            time.linking = try clock.measure
            {
                let scalarPositions:[[SymbolGraph.Namespace]] = linker.allocate(
                    namespaces: namespaces)
                let extensionPositions:[(Int32, Int)] = linker.allocate(
                    extensions: extensions)

                if  let supplements
                {
                    try linker.attach(supplements: supplements)
                }

                linker.link(namespaces: namespaces, at: scalarPositions)
                linker.link(extensions: extensions, at: extensionPositions)
            }

            let graph:SymbolGraph = try linker.finalize()

            print("Linked documentation in \(time.linking)")

            let symbolicator:Symbolicator = .init(graph: graph, root: artifacts.root)
            symbolicator.emit(diagnoses: linker.diagnoses, colors: .enabled)

            return graph
        }
    }
}
