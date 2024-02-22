import MarkdownABI
import MarkdownAST
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

struct Artifacts
{
    let directory:ArtifactsDirectory
    let parts:[SymbolGraphPart.ID]

    init(directory:ArtifactsDirectory, parts:consuming [SymbolGraphPart.ID])
    {
        parts.sort { $0.basename < $1.basename }

        self.directory = directory
        self.parts = parts
    }
}
extension Artifacts
{
    func load() throws -> [SymbolGraphPart]
    {
        try self.parts.map
        {
            let path:FilePath = self.directory.path / "\($0)"

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
