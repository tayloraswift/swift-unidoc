import SymbolGraphParts
import Testing

@Suite struct SystemProgrammingInterfaces {
    private let symbols: SymbolGraphPart

    init() throws {
        self.symbols = try .load(part: "TestModules/SymbolGraphs/SPI.symbols.json")
    }

    @Test(
        arguments: [
            (["NoSPI"], nil),
            (["SPI"],   []),
        ] as [([String], [String]?)]
    ) func Existence(_ symbol: [String], _ spis: [String]?) throws {
        let vertex: SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.signature.spis == spis)
    }
}
