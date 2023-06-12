import SymbolGraphs
import SymbolGraphParts
import UnidocCompiler
import UnidocLinker

extension Documentation
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
                for artifact:String in
                    culture.articles.map(\.string).sorted() +
                    culture.parts.map(\.description).sorted()
                {
                    print("Loading artifact: \(artifact)")
                }

                let parts:[SymbolGraphPart] = try culture.load()

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

            time.linking = clock.measure
            {
                let scalarAddresses:[[ClosedRange<Int32>]] = linker.allocate(
                    namespaces: namespaces)
                let extensionAddresses:[(Int32, Int)] = linker.allocate(
                    extensions: extensions)

                linker.link(namespaces: namespaces, at: scalarAddresses)
                linker.link(extensions: extensions, at: extensionAddresses)
            }

            print("Linked documentation in \(time.linking)")

            return linker.docs
        }
    }
}
