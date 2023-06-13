import JSON
import SymbolGraphParts
import System
import Testing

extension TestGroup
{
    func expect(symbol path:[String], in part:SymbolGraphPart) -> SymbolDescription?
    {
        self.expect(value: part.symbols.first
        {
            switch $0.usr
            {
            case .vector:   return false
            default:        return $0.path.elementsEqual(path)
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
            let part:SymbolGraphPart = try .init(parsing: try path.read([UInt8].self),
                id: id)

            self.expect(part.metadata.version ==? .v(0, 6, 0))

            return part
        }
    }
}
