import JSONDecoding
import PackageMetadata
import PackageGraphs
import UnidocCompiler
import UnidocLinker
import SymbolGraphs
import SymbolGraphParts
import System

@frozen public
struct DocumentationArtifacts
{
    public
    let metadata:DocumentationMetadata
    let cultures:[Culture]
    let root:Repository.Root?

    public
    init(metadata:DocumentationMetadata, cultures:[Culture], root:Repository.Root? = nil)
    {
        self.metadata = metadata
        self.cultures = cultures
        self.root = root
    }
}
extension DocumentationArtifacts
{
    public
    func build() async throws -> DocumentationArchive
    {
        let (scalars, nominations):([[Compiler.Scalar]], Compiler.Nominations)
        let (extensions):[Compiler.Extension]

        let clock:ContinuousClock = .init()
        var time:(compiling:Duration, linking:Duration)

        do
        {
            time.compiling = .zero

            var compiler:Compiler = .init(root: self.root)

            for culture:Culture in self.cultures
            {
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
                metadata: self.metadata,
                targets: self.cultures.map(\.node))

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
