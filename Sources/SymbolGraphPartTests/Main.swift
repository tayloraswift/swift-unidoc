import Signatures
import SymbolGraphParts
import Symbols
import System_
import Testing_

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "Phyla",
            let part:SymbolGraphPart = tests.load(
                part: "TestModules/SymbolGraphs/Phyla.symbols.json")
        {
            for (symbol, phylum):([String], Phylum.Decl) in
            [
                (["Actor"],                         .actor),
                (["Class"],                         .class),
                (["Enum"],                          .enum),
                (["Enum", "case"],                  .case),
                (["Protocol"],                      .protocol),
                (["Protocol", "AssociatedType"],    .associatedtype),
                (["Struct"],                        .struct),
                (["Typealias"],                     .typealias),
                (["Var"],                           .var(nil)),
            ]
            {
                if  let name:String = symbol.last?.lowercased(),
                    let tests:TestGroup = tests / name,
                    let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.phylum ==? .decl(phylum))
                }
            }
            for (symbol, phylum, name):([String], Phylum.Decl, String) in
            [
                (["Func"],                      .func(nil),             "global-func"),
                (["Struct", "instanceMethod"],  .func(.instance),       "instance-func"),
                (["Struct", "staticMethod"],    .func(.static),         "static-func"),

                (["Struct", "instanceProperty"],.var(.instance),        "instance-var"),
                (["Struct", "staticProperty"],  .var(.static),          "static-var"),

                (["Struct", "subscript"],       .subscript(.instance),  "instance-subscript"),
                (["Struct", "subscript(_:)"],   .subscript(.static),    "static-subscript"),

                (["Class", "classMethod"],      .func(.class),          "class-func"),
                (["Class", "classProperty"],    .var(.class),           "class-var"),
                (["Class", "init"],             .initializer,           "class-init"),
                (["Actor", "init"],             .initializer,           "actor-init"),

                (["?/(_:)"],                    .operator,              "operator-prefix"),
                (["<-(_:_:)"],                  .operator,              "operator-infix"),
                (["/?(_:)"],                    .operator,              "operator-suffix"),

                (["Struct", "?/(_:)"],          .operator,              "type-operator-prefix"),
                (["Struct", "<-(_:_:)"],        .operator,              "type-operator-infix"),
                (["Struct", "/?(_:)"],          .operator,              "type-operator-suffix"),
            ]
            {
                if  let tests:TestGroup = tests / name,
                    let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.phylum ==? .decl(phylum))
                }
            }

            if  let tests:TestGroup = tests / "deinit"
            {
                tests.expect(nil: part.vertices.first { $0.phylum == .decl(.deinitializer) })
            }
        }
        if  let tests:TestGroup = tests / "Phyla" / "Extension",
            let part:SymbolGraphPart = tests.load(
                part: "TestModules/SymbolGraphs/Phyla@Swift.symbols.json")
        {
            for (symbol, phylum):([String], Phylum) in
            [
                (["Int"], .block),
                (["Int", "AssociatedType"], .decl(.typealias)),
            ]
            {
                if  let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.phylum ==? phylum)
                }
            }
        }
        if  let tests:TestGroup = tests / "ACLs",
            let part:SymbolGraphPart = tests.load(
                part: "TestModules/SymbolGraphs/ACL.symbols.json")
        {
            for (symbol, level):([String], Symbol.ACL?) in
            [
                (["Public"],    .public),
                (["Package"],   .package),
                (["Internal"],  .internal),
            ]
            {
                if  let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.acl ==? level)
                }
            }
        }
        if  let tests:TestGroup = tests / "SPIs",
            let part:SymbolGraphPart = tests.load(
                part: "TestModules/SymbolGraphs/SPI.symbols.json")
        {
            for (symbol, interfaces):([String], [String]?) in
            [
                (["NoSPI"], nil),
                (["SPI"], []),
            ]
            {
                if  let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.signature.spis ==? interfaces)
                }
            }
        }
        if  let tests:TestGroup = tests / "InternalDocumentationInheritance",
            let part:SymbolGraphPart = tests.load(
                part: "TestModules/SymbolGraphs/DocumentationInheritance.symbols.json")
        {
            for (symbol, culture, comment):([String], Symbol.Module?, String?) in
            [
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
                    "DocumentationInheritance",
                    "This comment is from the root protocol."
                ),

                (
                    ["Conformer", "everywhere"],
                    "DocumentationInheritance",
                    "This comment is from the conforming type."
                ),
                //  NOTE:
                //  These should not be present if `-skip-inherited-docs` worked correctly,
                //  but they are, likely due to a compiler bug

                //  This would inherit (from Protocol) if the part
                //  were generated without `-skip-inherited-docs`.
                (
                    ["Conformer", "protocol"],
                    "DocumentationInheritance", // nil,
                    "This comment is from the root protocol." // nil,
                ),
                //  This would inherit (from Refinement) if the part
                //  were generated without `-skip-inherited-docs`.
                (
                    ["Conformer", "refinement"],
                    "DocumentationInheritance", // nil,
                    "This comment is from the refined protocol." // nil,
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
            ]
            {
                if  let tests:TestGroup = tests / symbol.joined(separator: "-").lowercased(),
                    let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.doccomment?.culture ==? culture)
                    tests.expect(symbol.doccomment?.text ==? comment)
                }
            }

            if  let tests:TestGroup = tests / "origins"
            {
                /// Concrete type members always get an origin edge pointing back
                /// to whatever requirement they fulfill, regardless of whether:
                ///
                /// -   they already have documentation of their own, or
                /// -   they had no documentation, and inherited no documentation.
                ///
                /// In both cases, they will get an edge to their immediate origin.
                /// If concrete type members do inherit documentation, their origin
                /// edges point to the symbols they inherited documenation from,
                /// even if there were undocumented symbols in between. (The edges
                /// “skip” the undocumented symbols.)
                ///
                /// Default implementations only get an origin edge if they actually
                /// had no documentation of their own, and successfully inherited some.
                tests.expect(part.relationships.filter
                {
                    $0.origin != nil
                }
                    **?
                [
                    .intrinsicWitness(.init(
                        _ : "s24DocumentationInheritance15OtherRefinementPAAE8protocolytvp",
                        of: "s24DocumentationInheritance8ProtocolP8protocolytvp",
                        origin: .init("s24DocumentationInheritance8ProtocolP8protocolytvp"))),

                    .member(.init(
                        _ : "s24DocumentationInheritance9ConformerV7nowhereytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: .init("s24DocumentationInheritance10RefinementP7nowhereytvp"))),

                    .member(.init(
                        _ : "s24DocumentationInheritance9ConformerV10refinementytvp",
                        in: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: .init(.init(
                            "s:24DocumentationInheritance10RefinementP10refinementytvp")!))),

                    .member(.init(
                        _ : "s24DocumentationInheritance9ConformerV9conformerytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: .init(
                            "s24DocumentationInheritance10RefinementP9conformerytvp"))),

                    .member(.init(
                        _ : "s24DocumentationInheritance9ConformerV10everywhereytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: .init(
                            "s24DocumentationInheritance10RefinementP10everywhereytvp"))),

                    .member(.init(
                        _ : "s24DocumentationInheritance9ConformerV8protocolytvp",
                        in: .scalar("s24DocumentationInheritance9ConformerV"),
                        origin: .init(
                            "s24DocumentationInheritance8ProtocolP8protocolytvp"))),
                ])
            }
        }
        if  let tests:TestGroup = tests / "ExternalDocumentationInheritance",
            let part:SymbolGraphPart = tests.load(part: """
                TestModules/SymbolGraphs/DocumentationInheritanceFromSwift.symbols.json
                """)
        {
            for (symbol, culture, comment):([String], Symbol.Module?, String?) in
            [
                (
                    ["Documented", "id"],
                    "DocumentationInheritanceFromSwift",
                    "A documented id property."
                ),
                (
                    ["Undocumented", "id"],
                    "Swift",
                    "The stable identity of the entity associated with this instance."
                ),
            ]
            {
                if  let tests:TestGroup = tests / symbol[0].lowercased(),
                    let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.doccomment?.culture ==? culture)
                    tests.expect(symbol.doccomment?.text ==? comment)
                }
            }

            if  let tests:TestGroup = tests / "origins"
            {
                /// Concrete type members always get an origin edge pointing back
                /// to whatever requirement they fulfill, regardless of whether:
                ///
                /// -   they already have documentation of their own, or
                /// -   they had no documentation, and inherited no documentation.
                ///
                /// In both cases, they will get an edge to their immediate origin.
                /// If concrete type members do inherit documentation, their origin
                /// edges point to the symbols they inherited documenation from,
                /// even if there were undocumented symbols in between. (The edges
                /// “skip” the undocumented symbols.)
                ///
                /// Default implementations only get an origin edge if they actually
                /// had no documentation of their own, and successfully inherited some.
                tests.expect(part.relationships.filter
                {
                    if  case .member(let membership) = $0,
                        case _? = membership.origin
                    {
                        true
                    }
                    else
                    {
                        false
                    }
                }
                    **?
                [
                    .member(.init("""
                        s33DocumentationInheritanceFromSwift12UndocumentedV2ids5NeverOSgvp
                        """,
                        in: .scalar("s33DocumentationInheritanceFromSwift12UndocumentedV"),
                        origin: "ss12IdentifiableP2id2IDQzvp")),

                    .member(.init("""
                        s33DocumentationInheritanceFromSwift10DocumentedV2ids5NeverOSgvp
                        """,
                        in: .scalar("s33DocumentationInheritanceFromSwift10DocumentedV"),
                        origin: "ss12IdentifiableP2id2IDQzvp")),
                ])
            }
        }

        if  let tests:TestGroup = tests / "InternalExtensionConstraints",
            let part:SymbolGraphPart = tests.load(part: """
                TestModules/SymbolGraphs/InternalExtensionsWithConstraints.symbols.json
                """)
        {
            for (symbol, conditions):([String], [GenericConstraint<Symbol.Decl>]) in
            [
                (
                    ["Struct", "internal(_:)"],
                    [
                        .where("T", is: .conformer, to: .init(
                            spelling: "Equatable",
                            nominal: "sSQ")),
                        .where("T", is: .conformer, to: .init(
                            spelling: "Sequence",
                            nominal: "sST")),
                    ]
                ),
                (
                    ["Protocol", "internal(_:)"],
                    [
                        .where("Self.T", is: .conformer, to: .init(
                            spelling: "Equatable",
                            nominal: "sSQ")),
                    ]
                ),
            ]
            {
                if  let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.extension.conditions ..? conditions)
                }
            }
        }
        if  let tests:TestGroup = tests / "ExternalExtensionConstraints",
            let part:SymbolGraphPart = tests.load(part: """
                TestModules/SymbolGraphs/\
                ExternalExtensionsWithConstraints@\
                ExtendableTypesWithConstraints.symbols.json
                """)
        {
            for (symbol, conditions):([String], [GenericConstraint<Symbol.Decl>]) in
            [
                (
                    ["Struct"],
                    [
                        .where("T", is: .conformer, to: .init(
                            spelling: "Equatable",
                            nominal: "sSQ")),
                        .where("T", is: .conformer, to: .init(
                            spelling: "Sequence",
                            nominal: "sST")),
                    ]
                ),
                (
                    ["Struct", "external(_:)"],
                    [
                        .where("T", is: .conformer, to: .init(
                            spelling: "Equatable",
                            nominal: "sSQ")),
                        .where("T", is: .conformer, to: .init(
                            spelling: "Sequence",
                            nominal: "sST")),
                    ]
                ),
                (
                    ["Protocol"],
                    [
                        .where("Self.T", is: .conformer, to: .init(
                            spelling: "Equatable",
                            nominal: "sSQ")),
                    ]
                ),
                (
                    ["Protocol", "external(_:)"],
                    [
                        .where("Self.T", is: .conformer, to: .init(
                            spelling: "Equatable",
                            nominal: "sSQ")),
                    ]
                ),
            ]
            {
                if  let symbol:SymbolGraphPart.Vertex = tests.expect(symbol: symbol, in: part)
                {
                    tests.expect(symbol.extension.conditions ..? conditions)
                }
            }
        }
    }
}
