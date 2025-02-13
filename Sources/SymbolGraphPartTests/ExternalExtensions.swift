import Signatures
import SymbolGraphParts
import Symbols
import Testing

@Suite
struct ExternalExtensions
{
    private
    let symbols:SymbolGraphPart

    init() throws
    {
        self.symbols = try .load(part: """
            TestModules/SymbolGraphs/ExternalExtensionsWithConstraints@\
            ExtendableTypesWithConstraints.symbols.json
            """)
    }

    @Test(arguments: [
            (
                ["Struct"],
                [
                    .where("T", is: .conformer, to: .Equatable),
                    .where("T", is: .conformer, to: .Sequence),
                ]
            ),
            (
                ["Struct", "external(_:)"],
                [
                    .where("T", is: .conformer, to: .Equatable),
                    .where("T", is: .conformer, to: .Sequence),
                ]
            ),
            (
                ["Protocol"],
                [
                    .where("Self.T", is: .conformer, to: .Equatable),
                ]
            ),
            (
                ["Protocol", "external(_:)"],
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
