import JSONDecoding
import SymbolGraphParts
import System
import Testing

extension TestGroup
{
    func expect(symbol path:[String], in part:SymbolGraphPart) -> SymbolGraphPart.Vertex?
    {
        self.expect(value: part.vertices.first
        {
            switch $0.usr
            {
            case .vector:   false
            default:        $0.path.elementsEqual(path)
            }
        })
    }
    func load(part path:FilePath) -> SymbolGraphPart?
    {
        guard   let id:FilePath.Component = self.expect(value: path.lastComponent),
                let id:SymbolGraphPart.ID = .init(id.string)
        else
        {
            return nil
        }
        return self.do
        {
            let part:SymbolGraphPart = try .init(
                json: .init(utf8: try path.read([UInt8].self)[...]),
                id: id)

            self.expect(part.metadata.version ==? .v(0, 6, 0))

            return part
        }
    }
}
