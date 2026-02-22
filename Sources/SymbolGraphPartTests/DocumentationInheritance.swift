import SymbolGraphParts
import Symbols
import Testing

@Suite struct DocumentationInheritance {
    private let symbols: SymbolGraphPart

    init() throws {
        self.symbols = try .load(
            part: "TestModules/SymbolGraphs/DocumentationInheritance.symbols.json"
        )
    }

    @Test(
        arguments: [
            (
                ["Protocol", "everywhere"],
                "DocumentationInheritance",
                "This comment is from the root protocol."
            ),
            (
                ["Protocol", "protocol"],
                "DocumentationInheritance",
                "This comment is from the root protocol."
            ),
            (
                ["Protocol", "refinement"],
                nil,
                nil
            ),
            (
                ["Protocol", "conformer"],
                nil,
                nil
            ),
            (
                ["Protocol", "nowhere"],
                nil,
                nil
            ),

            (
                ["Refinement", "everywhere"],
                "DocumentationInheritance",
                "This comment is from the refined protocol."
            ),
            (
                ["Refinement", "protocol"],
                nil,
                nil
            ),
            (
                ["Refinement", "refinement"],
                "DocumentationInheritance",
                "This comment is from the refined protocol."
            ),
            (
                ["Refinement", "conformer"],
                nil,
                nil
            ),
            (
                ["Refinement", "nowhere"],
                nil,
                nil
            ),

            (
                ["OtherRefinement", "everywhere"],
                "DocumentationInheritance",
                "This is a default implementation provided by a refined protocol."
            ),
            (
                ["OtherRefinement", "protocol"],
                nil,
                nil
            ),

            (
                ["Conformer", "everywhere"],
                "DocumentationInheritance",
                "This comment is from the conforming type."
            ),

            //  This would inherit (from Protocol) if the part
            //  were generated without `-skip-inherited-docs`.
            (
                ["Conformer", "protocol"],
                nil,
                nil
            ),
            //  This would inherit (from Refinement) if the part
            //  were generated without `-skip-inherited-docs`.
            (
                ["Conformer", "refinement"],
                nil,
                nil
            ),
            (
                ["Conformer", "conformer"],
                "DocumentationInheritance",
                "This comment is from the conforming type."
            ),
            (
                ["Conformer", "nowhere"],
                nil,
                nil
            ),
        ] as [([String], Symbol.Module?, String?)]
    ) func Comments(_ symbol: [String], _ culture: Symbol.Module?, _ comment: String?) throws {
        let vertex: SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.doccomment?.culture == culture)
        #expect(vertex?.doccomment?.text == comment)
    }

    @Test func Origins() throws {
        let relationships: Set<Symbol.AnyRelationship> = self.symbols.relationships.reduce(
            into: []
        ) {
            if  case _? = $1.origin {
                $0.insert($1)
            }
        }

        #expect(
            relationships == [
                .intrinsicWitness(
                    .init(
                        _: "s24DocumentationInheritance15OtherRefinementPAAE8protocolytvp",
                        of: "s24DocumentationInheritance8ProtocolP8protocolytvp",
                        origin: "s24DocumentationInheritance8ProtocolP8protocolytvp"
                    )
                ),

                .requirement(
                    .init(
                        _: "s24DocumentationInheritance10RefinementP8protocolytvp",
                        of: "s24DocumentationInheritance10RefinementP",
                        origin: "s24DocumentationInheritance8ProtocolP8protocolytvp"
                    )
                ),

                .override(
                    .init(
                        _: "s24DocumentationInheritance10RefinementP8protocolytvp",
                        of: "s24DocumentationInheritance8ProtocolP8protocolytvp",
                        origin: "s24DocumentationInheritance8ProtocolP8protocolytvp"
                    )
                ),

                .member(
                    .init(
                        _: "s24DocumentationInheritance9ConformerV7nowhereytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: "s24DocumentationInheritance10RefinementP7nowhereytvp"
                    )
                ),

                .member(
                    .init(
                        _: "s24DocumentationInheritance9ConformerV10refinementytvp",
                        in: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: "s24DocumentationInheritance10RefinementP10refinementytvp"
                    )
                ),

                .member(
                    .init(
                        _: "s24DocumentationInheritance9ConformerV9conformerytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: "s24DocumentationInheritance10RefinementP9conformerytvp"
                    )
                ),

                .member(
                    .init(
                        _: "s24DocumentationInheritance9ConformerV10everywhereytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: "s24DocumentationInheritance10RefinementP10everywhereytvp"
                    )
                ),

                .member(
                    .init(
                        _: "s24DocumentationInheritance9ConformerV8protocolytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: "s24DocumentationInheritance8ProtocolP8protocolytvp"
                    )
                ),
            ]
        )
    }
}
