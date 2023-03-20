import JSON
import SymbolColonies
import System
import Testing

extension TestGroup
{
    func load(colonies filepaths:[FilePath]) -> [SymbolColony]
    {
        self.do
        {
            try filepaths.map
            {
                let file:[UInt8] = try $0.read()

                let json:JSON.Object = try .init(parsing: file)
                let colony:SymbolColony = try .init(json: json)

                self.expect(colony.metadata.version ==? .v(0, 6, 0))

                return colony
            }
        } ?? []
    }
}
