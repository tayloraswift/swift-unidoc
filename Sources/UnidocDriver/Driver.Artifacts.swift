import JSONDecoding
import PackageMetadata
import PackageGraphs
import UnidocCompiler
import UnidocLinker
import SymbolGraphs
import SymbolGraphParts
import System

extension Driver
{
    @frozen public
    struct Artifacts
    {
        public
        let metadata:SymbolGraph.Metadata
        let cultures:[Culture]
        let root:Repository.Root?

        public
        init(metadata:SymbolGraph.Metadata, cultures:[Culture], root:Repository.Root? = nil)
        {
            self.metadata = metadata
            self.cultures = cultures
            self.root = root
        }
    }
}
extension Driver.Artifacts
{
    public
    func buildDocumentation() async throws -> SymbolGraph
    {
        let (scalars, nominations):([[Compiler.Scalar]], Compiler.Nominations)
        let (extensions):[Compiler.Extension]

        let clock:ContinuousClock = .init()
        var time:(compiling:Duration, linking:Duration)

        do
        {
            time.compiling = .zero

            var compiler:Compiler = .init(root: self.root)

            for culture:Driver.Culture in self.cultures
            {
                let parts:[SymbolGraphPart] = try culture.parts.map
                {
                    try .init(parsing: try $0.read([UInt8].self))
                }
                time.compiling += try clock.measure
                {
                    try compiler.compile(culture: culture.id, parts: parts)
                }
            }

            (scalars, nominations) = compiler.scalars.load()
            (extensions) = compiler.extensions.load()

            print("Compiled documentation in \(time.compiling)")
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

            return linker.graph
        }
    }
}
