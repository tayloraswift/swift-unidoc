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
            let file:[UInt8] = try filepath.read()

            let json:JSON.Object = try .init(parsing: file)
            let part:SymbolGraphPart = try .init(json: json)

            self.expect(part.metadata.version ==? .v(0, 6, 0))

            return part
        }
    }
}
