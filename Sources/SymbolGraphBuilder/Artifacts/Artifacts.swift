import MarkdownABI
import MarkdownAST
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

struct Artifacts
{
    let location:FilePath.Directory
    var parts:[SymbolGraphPart.ID]

    init(location:FilePath.Directory, parts:consuming [SymbolGraphPart.ID])
    {
        self.location = location
        self.parts = parts
        self.parts.sort { $0.basename < $1.basename }
    }
}
extension Artifacts
{
    func load() throws -> [SymbolGraphPart]
    {
        try self.parts.map
        {
            let path:FilePath = self.location / "\($0)"

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
