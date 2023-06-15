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
                for part:SymbolGraphPart in parts
                {
                    print("Loaded artifact: \(part.id)")
                }

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

            let supplements:[[(name:String, text:String)]] = try artifacts.cultures.map
            {
                try $0.loadArticles()
            }
            for (name, _):(String, String) in supplements.joined()
            {
                print("Loaded artifact: \(name)")
            }

            time.linking = try clock.measure
            {
                let scalarPositions:[[SymbolGraph.Namespace]] = linker.allocate(
                    namespaces: namespaces)
                let extensionPositions:[(Int32, Int)] = linker.allocate(
                    extensions: extensions)

                try linker.attach(supplements: supplements)

                linker.link(namespaces: namespaces, at: scalarPositions)
                linker.link(extensions: extensions, at: extensionPositions)
            }

            print("Linked documentation in \(time.linking)")

            return linker.graph
        }
    }
}
