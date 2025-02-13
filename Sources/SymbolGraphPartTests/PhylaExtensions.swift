import SymbolGraphParts
import Symbols
import Testing

@Suite
struct PhylaExtensions
{
    private
    let symbols:SymbolGraphPart

    init() throws
    {
        self.symbols = try .load(part: "TestModules/SymbolGraphs/Phyla@Swift.symbols.json")
    }

    @Test(arguments: [
            (["Int"], .block),
            (["Int", "AssociatedType"], .decl(.typealias)),
        ] as [([String], Phylum)])
    func Blocks(_ symbol:[String], phylum:Phylum) throws
    {
        let vertex:SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.phylum == phylum)
    }
}
