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
    func load(part filepath:FilePath) -> SymbolGraphPart?
    {
        self.do
        {
            let part:SymbolGraphPart = try .init(parsing: try filepath.read([UInt8].self),
                id: filepath.components.last?.stem)

            self.expect(part.metadata.version ==? .v(0, 6, 0))

            return part
        }
    }
}
