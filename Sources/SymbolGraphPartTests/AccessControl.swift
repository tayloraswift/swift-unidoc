import SymbolGraphParts
import Symbols
import Testing

@Suite struct AccessControl {
    private let symbols: SymbolGraphPart

    init() throws {
        self.symbols = try .load(part: "TestModules/SymbolGraphs/ACL.symbols.json")
    }

    @Test(
        arguments: [
            (["Public"],    .public),
            (["Package"],   .package),
            (["Internal"],  .internal),
        ] as [([String], Symbol.ACL)]
    ) func Levels(_ symbol: [String], acl: Symbol.ACL) throws {
        let vertex: SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.acl == acl)
    }
}
