import JSON
import SymbolColonies
import System
import Testing

extension TestGroup
{
    func expect(symbol path:[String], in colony:SymbolColony) -> SymbolDescription?
    {
        self.expect(value: colony.symbols.first
        {
            switch $0.usr
            {
            case .compound: return false
            default:        return $0.path.elementsEqual(path)
            }
        })
    }
    func load(colony filepath:FilePath) -> SymbolColony?
    {
        self.do
        {
            let file:[UInt8] = try filepath.read()

            let json:JSON.Object = try .init(parsing: file)
            let colony:SymbolColony = try .init(json: json)

            self.expect(colony.metadata.version ==? .v(0, 6, 0))

            return colony
        }
    }
}
