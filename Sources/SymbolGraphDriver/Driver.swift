import JSONDecoding
import Repositories
import SymbolGraphCompiler
import SymbolGraphLinker
import SymbolGraphParts
import System

public
enum Driver
{
    public static
    func build(metadata:SymbolGraph.Metadata,
        parts:[FilePath],
        root:Repository.Root? = nil) throws -> SymbolGraph
    {
        let extensions:[Compiler.Extension]

        let scalars:[Compiler.Scalar]
        let context:Compiler.ScalarNominations

        do
        {
            var compiler:Compiler = .init(root: root)

            let parts:[SymbolGraphPart] = try parts.map
            {
                try .init(json: try JSON.Object.init(parsing: try $0.read([UInt8].self)))
            }

            try compiler.compile(parts: parts)

            (extensions) = compiler.extensions.load()
            (scalars, context) = compiler.scalars.load()
        }
        do
        {
            var linker:Linker = .init(metadata: metadata, context: context)

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
