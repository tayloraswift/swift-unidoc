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
                let file:[UInt8] = try $0.read()

                let json:JSON.Object = try .init(parsing: file)
                let part:SymbolGraphPart = try .init(json: json)

                self.expect(part.metadata.version ==? .v(0, 6, 0))

                return part
            }
        } ?? []
    }
}
