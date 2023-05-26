import SymbolGraphs
import SymbolGraphParts
import UnidocCompiler
import UnidocLinker

extension DocumentationArchive
{
    public static
    func build(from artifacts:Artifacts) async throws -> Self
    {
        let (scalars, nominations):([[Compiler.Scalar]], Compiler.Nominations)
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
                    culture.parts.map(\.string).sorted()
                {
                    print("Loading artifact: \(artifact)")
                }

                let parts:[SymbolGraphPart] = try culture.load()

                time.compiling += try clock.measure
                {
                    try compiler.compile(culture: culture.id, parts: parts)
                }
            }

            (scalars, nominations) = compiler.scalars.load()
            (extensions) = compiler.extensions.load()

            print("""
                Compiled documentation in \(time.compiling) \
                (\(scalars.count) culture(s), containing \
                \(scalars.reduce(0) { $0 + $1.count }) declaration(s) and \
                \(extensions.count) extension(s))
                """)
        }
        do
        {
            var linker:Linker = .init(nominations: nominations,
                modules: artifacts.cultures.map(\.module))

            time.linking = try clock.measure
            {
                let scalarAddresses:[[ScalarAddress]] = try linker.allocate(
                    scalars: scalars)
                let extensionAddresses:[(ScalarAddress, Int)] = try linker.allocate(
                    extensions: extensions)

                try linker.link(scalars: scalars, at: scalarAddresses)
                try linker.link(extensions: extensions, at: extensionAddresses)
            }

            print("Linked documentation in \(time.linking)")

            return linker.archive
        }
    }
}
