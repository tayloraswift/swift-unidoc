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
    func buildSymbolGraph() async throws -> SymbolGraph
    {
        let (scalars, nominations):([Compiler.Culture], Compiler.Nominations)
        let (extensions):[Compiler.Extension]

        do
        {
            var compiler:Compiler = .init(root: self.root)

            for culture:Driver.Culture in self.cultures
            {
                try compiler.compile(culture: culture.id,
                    parts: try culture.parts.map
                {
                    try .init(parsing: try $0.read([UInt8].self))
                })
            }

            (scalars, nominations) = compiler.scalars.load()
            (extensions) = compiler.extensions.load()
        }
        do
        {
            var linker:Linker = .init(nominations: nominations, metadata: self.metadata)

            let scalarAddresses:[[ScalarAddress]] = try linker.allocate(
                scalars: scalars)
            let extensionAddresses:[(ScalarAddress, Int)] = try linker.allocate(
                extensions: extensions)

            try linker.link(scalars: scalars, at: scalarAddresses)
            try linker.link(extensions: extensions, at: extensionAddresses)

            return linker.graph
        }
    }
}
