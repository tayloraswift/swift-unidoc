import Signatures
import SymbolGraphParts
import Symbols
import Testing

@Suite
struct InternalExtensions
{
    private
    let symbols:SymbolGraphPart

    init() throws
    {
        self.symbols = try .load(
            part: "TestModules/SymbolGraphs/InternalExtensionsWithConstraints.symbols.json")
    }

    @Test(arguments: [
            (
                ["Struct", "internal(_:)"],
                [
                    .where("T", is: .conformer, to: .Equatable),
                    .where("T", is: .conformer, to: .Sequence),
                ]
            ),
            (
                ["Protocol", "internal(_:)"],
                [
                    .where("Self.T", is: .conformer, to: .Equatable),
                ]
            ),
        ] as [([String], [GenericConstraint<Symbol.Decl>])])
    func Constraints(_ symbol:[String], _ conditions:[GenericConstraint<Symbol.Decl>]) throws
    {
        let vertex:SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.extension.conditions == conditions)
    }
}
