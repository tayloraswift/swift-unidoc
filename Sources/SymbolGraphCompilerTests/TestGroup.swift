import JSONDecoding
import SymbolGraphParts
import System
import Testing

extension TestGroup
{
    func load(parts filepaths:[FilePath]) -> [SymbolGraphPart]
    {
        filepaths.compactMap
        {
            (path:FilePath) in

            guard   let id:FilePath.Component = self.expect(value: path.lastComponent),
                    let id:SymbolGraphPart.ID = .init(id.string)
            else
            {
                return nil
            }
            return self.do
            {
                let part:SymbolGraphPart = try .init(
                    json: .init(utf8: try path.read([UInt8].self)),
                    id: id)

                self.expect(part.metadata.version ==? .v(0, 6, 0))

                return part
            }
        }
    }
}
