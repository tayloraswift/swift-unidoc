import JSON
import SymbolGraphParts
import System
import Testing

extension TestGroup
{
    func load(parts filepaths:[FilePath]) -> [SymbolGraphPart]
    {
        self.do
        {
            try filepaths.map
            {
                let part:SymbolGraphPart = try .init(parsing: try $0.read([UInt8].self),
                    id: $0.components.last?.string)

                self.expect(part.metadata.version ==? .v(0, 6, 0))

                return part
            }
        } ?? []
    }
}
