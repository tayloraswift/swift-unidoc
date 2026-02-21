import SymbolGraphParts
import Symbols
import Testing

@Suite struct Reexports {
    private let symbols: SymbolGraphPart

    init() throws {
        self.symbols = try .load(part: "TestModules/SymbolGraphs/Reexports.symbols.json")
    }

    @Test func Existence() throws {
        #expect(nil != self.symbols.first(named: ["Public"]))
    }
}
