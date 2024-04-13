import MarkdownABI
import MarkdownAST
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

struct Artifacts
{
    let parts:[SymbolGraphPart.ID]
    let path:FilePath

    init(parts:consuming [SymbolGraphPart.ID], in path:FilePath)
    {
        parts.sort { $0.basename < $1.basename }

        self.parts = parts
        self.path = path
    }
}
extension Artifacts
{
    func load() throws -> [SymbolGraphPart]
    {
        try self.parts.map
        {
            let path:FilePath = self.path / "\($0)"

            print("Loading symbols: \($0)")

            do
            {
                return try .init(json: .init(utf8: try path.read()[...]), id: $0)
            }
            catch let error
            {
                throw ArtifactError.init(underlying: error, path: path)
            }
        }
    }
}
