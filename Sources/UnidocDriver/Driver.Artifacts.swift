import JSONDecoding
import PackageMetadata
import Repositories
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
        let extensions:[Compiler.Extension]

        let scalars:[Compiler.Scalar]
        let context:Compiler.ScalarNominations

        do
        {
            var compiler:Compiler = .init(root: self.root)

            for culture:Driver.Culture in self.cultures
            {
                try compiler.compile(culture: try culture.parts.map
                {
                    try .init(parsing: try $0.read([UInt8].self))
                })
            }

            (extensions) = compiler.extensions.load()
            (scalars, context) = compiler.scalars.load()
        }
        do
        {
            var linker:Linker = .init(metadata: self.metadata, context: context)

            let scalarAddresses:[ScalarAddress] = try linker.allocate(
                scalars: scalars)
            let extensionAddresses:[(ScalarAddress, Int)] = try linker.allocate(
                extensions: extensions)

            try linker.link(scalars: scalars, at: scalarAddresses)
            try linker.link(extensions: extensions, at: extensionAddresses)

            return linker.graph
        }
    }
}
