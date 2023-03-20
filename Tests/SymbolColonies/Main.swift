import SymbolColonies
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "phyla",
            let colony:SymbolColony = tests.load(
                colony: "TestModules/Symbolgraphs/Phyla.symbols.json")
        {
            for (symbol, phylum):(SymbolPath, SymbolPhylum) in
            [
                ("Actor", .actor),
                ("Class", .class),
                ("Enum", .enum),
                ("Enum" / "case", .case),
                ("Protocol", .protocol),
                ("Protocol" / "AssociatedType", .associatedtype),
                ("Struct", .struct),
                ("Typealias", .typealias),
                ("Var", .var),

            ]
            {
                if  let tests:TestGroup = tests / symbol.last.lowercased(),
                    let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.phylum ==? phylum)
                }
            }
            for (symbol, phylum, name):(SymbolPath, SymbolPhylum, String) in
            [
                ("Func",                        .func,              "global-func"),
                ("Struct" / "typeMethod",       .typeMethod,        "type-method"),
                ("Struct" / "instanceMethod",   .instanceMethod,    "instance-method"),
                
                ("Struct" / "subscript(_:)",    .typeSubscript,     "type-subscript"),
                ("Struct" / "subscript",        .instanceSubscript, "instance-subscript"),

                ("Class" / "init",              .initializer,       "class-init"),
                ("Actor" / "init",              .initializer,       "actor-init"),

                ("?/(_:)",                      .operator,          "global-operator-prefix"),
                ("<-(_:_:)",                    .operator,          "global-operator-infix"),
                ("/?(_:)",                      .operator,          "global-operator-suffix"),

                ("Struct" / "?/(_:)",           .typeOperator,      "type-operator-prefix"),
                ("Struct" / "<-(_:_:)",         .typeOperator,      "type-operator-infix"),
                ("Struct" / "/?(_:)",           .typeOperator,      "type-operator-suffix"),
            ]
            {
                if  let tests:TestGroup = tests / name,
                    let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.phylum ==? phylum)
                }
            }

            if  let tests:TestGroup = tests / "deinit"
            {
                tests.expect(nil: colony.symbols.first { $0.phylum == .deinitializer })
            }
        }
        if  let tests:TestGroup = tests / "phyla" / "extension",
            let colony:SymbolColony = tests.load(
                colony: "TestModules/Symbolgraphs/Phyla@Swift.symbols.json")
        {
            for (symbol, phylum):(SymbolPath, SymbolPhylum) in
            [
                ("Int", .extension),
                ("Int" / "AssociatedType", .typealias),
            ]
            {
                if  let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.phylum ==? phylum)
                }
            }
        }
        if  let tests:TestGroup = tests / "spi",
            let colony:SymbolColony = tests.load(
                colony: "TestModules/Symbolgraphs/SPI.symbols.json")
        {
            for (symbol, interfaces):(SymbolPath, SymbolInterfaces?) in
            [
                ("NoSPI", nil),
                ("SPI", .init()),
            ]
            {
                if  let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.interfaces ==? interfaces)
                }
            }
        }
        if  let tests:TestGroup = tests / "internal-documentation-inheritance",
            let colony:SymbolColony = tests.load(
                colony: "TestModules/Symbolgraphs/DocumentationInheritance.symbols.json")
        {
            for (symbol, culture, text):(SymbolPath, ModuleIdentifier?, String?) in
            [
                (
                    "Protocol" / "everywhere" as SymbolPath,
                    "DocumentationInheritance",
                    "This comment is from the root protocol."
                ),
                (
                    "Protocol" / "protocol" as SymbolPath,
                    "DocumentationInheritance",
                    "This comment is from the root protocol."
                ),
                (
                    "Protocol" / "refinement" as SymbolPath,
                    nil,
                    nil
                ),
                (
                    "Protocol" / "conformer" as SymbolPath,
                    nil,
                    nil
                ),
                (
                    "Protocol" / "nowhere" as SymbolPath,
                    nil,
                    nil
                ),

                (
                    "Refinement" / "everywhere" as SymbolPath,
                    "DocumentationInheritance",
                    "This comment is from the refined protocol."
                ),
                (
                    "Refinement" / "protocol" as SymbolPath,
                    nil,
                    nil
                ),
                (
                    "Refinement" / "refinement" as SymbolPath,
                    "DocumentationInheritance",
                    "This comment is from the refined protocol."
                ),
                (
                    "Refinement" / "conformer" as SymbolPath,
                    nil,
                    nil
                ),
                (
                    "Refinement" / "nowhere" as SymbolPath,
                    nil,
                    nil
                ),

                (
                    "OtherRefinement" / "everywhere" as SymbolPath,
                    "DocumentationInheritance",
                    "This is a default implementation provided by a refined protocol."
                ),
                (
                    "OtherRefinement" / "protocol" as SymbolPath,
                    nil,
                    nil
                ),

                (
                    "Conformer" / "everywhere" as SymbolPath,
                    "DocumentationInheritance",
                    "This comment is from the conforming type."
                ),
                //  This would inherit (from Protocol) if the colony
                //  were generated without `-skip-inherited-docs`.
                (
                    "Conformer" / "protocol" as SymbolPath,
                    nil,
                    nil
                ),
                //  This would inherit (from Refinement) if the colony
                //  were generated without `-skip-inherited-docs`.
                (
                    "Conformer" / "refinement" as SymbolPath,
                    nil,
                    nil
                ),
                (
                    "Conformer" / "conformer" as SymbolPath,
                    "DocumentationInheritance",
                    "This comment is from the conforming type."
                ),
                (
                    "Conformer" / "nowhere" as SymbolPath,
                    nil,
                    nil
                ),
            ]
            {
                if  let tests:TestGroup = tests / symbol[0].lowercased() / symbol.last,
                    let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.documentation?.culture ==? culture)
                    tests.expect(symbol.documentation?.text ==? text)
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
                tests.expect(colony.relationships.filter
                {
                    $0.origin != nil
                }
                    **?
                [
                    .init(.scalar(.init(
                        "s:24DocumentationInheritance15OtherRefinementPAAE8protocolytvp")!),
                        is: .defaultImplementation,
                        of: .scalar(.init(
                            "s:24DocumentationInheritance8ProtocolP8protocolytvp")!),
                        origin: .init(
                            "s:24DocumentationInheritance8ProtocolP8protocolytvp")!),
                    
                    .init(.scalar(.init(
                        "s:24DocumentationInheritance9ConformerV7nowhereytvp")!),
                        is: .member,
                        of: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: .init(
                            "s:24DocumentationInheritance10RefinementP7nowhereytvp")!),
                    
                    .init(.scalar(.init(
                        "s:24DocumentationInheritance9ConformerV10refinementytvp")!),
                        is: .member,
                        of: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: .init(
                            "s:24DocumentationInheritance10RefinementP10refinementytvp")!),
                    
                    .init(.scalar(.init(
                        "s:24DocumentationInheritance9ConformerV9conformerytvp")!),
                        is: .member,
                        of: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: .init(
                            "s:24DocumentationInheritance10RefinementP9conformerytvp")!),
                    
                    .init(.scalar(.init(
                        "s:24DocumentationInheritance9ConformerV10everywhereytvp")!),
                        is: .member,
                        of: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: .init(
                            "s:24DocumentationInheritance10RefinementP10everywhereytvp")!),
    
                    .init(.scalar(.init(
                        "s:24DocumentationInheritance9ConformerV8protocolytvp")!),
                        is: .member,
                        of: .scalar(.init("s:24DocumentationInheritance9ConformerV")!),
                        origin: .init(
                            "s:24DocumentationInheritance8ProtocolP8protocolytvp")!),
                ])
            }
        }
        if  let tests:TestGroup = tests / "external-documentation-inheritance",
            let colony:SymbolColony = tests.load(colony: """
                TestModules/Symbolgraphs/DocumentationInheritanceFromSwift.symbols.json
                """)
        {
            for (symbol, culture, text):(SymbolPath, ModuleIdentifier?, String?) in
            [
                (
                    "Documented" / "id" as SymbolPath,
                    "DocumentationInheritanceFromSwift",
                    "A documented id property."
                ),
                (
                    "Undocumented" / "id" as SymbolPath,
                    nil,
                    nil
                ),
            ]
            {
                if  let tests:TestGroup = tests / symbol[0].lowercased(),
                    let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.documentation?.culture ==? culture)
                    tests.expect(symbol.documentation?.text ==? text)
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
                tests.expect(colony.relationships.filter
                {
                    if case _? = $0.origin, case .scalar = $0.source
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
                    **?
                [
                    .init(.scalar(.init(
                        "s:33DocumentationInheritanceFromSwift12UndocumentedV2ids5NeverOSgvp")!),
                        is: .member,
                        of: .scalar(.init(
                        "s:33DocumentationInheritanceFromSwift12UndocumentedV")!),
                        origin: .init("s:s12IdentifiableP2id2IDQzvp")!),
                    
                    .init(.scalar(.init(
                        "s:33DocumentationInheritanceFromSwift10DocumentedV2ids5NeverOSgvp")!),
                        is: .member,
                        of: .scalar(.init(
                        "s:33DocumentationInheritanceFromSwift10DocumentedV")!),
                        origin: .init("s:s12IdentifiableP2id2IDQzvp")!),
                ])
            }
        }
        
        if  let tests:TestGroup = tests / "internal-extension-constraints",
            let colony:SymbolColony = tests.load(colony: """
                TestModules/Symbolgraphs/InternalExtensionsWithConstraints.symbols.json
                """)
        {
            for (symbol, conditions):(SymbolPath, [GenericConstraint<SymbolIdentifier>]) in
            [
                (
                    "Struct" / "internal(_:)",
                    [
                        .init("T", is: .conformer(of: .nominal(.init("s", ascii: "SQ")))),
                        .init("T", is: .conformer(of: .nominal(.init("s", ascii: "ST")))),
                    ]
                ),
                (
                    "Protocol" / "internal(_:)",
                    [
                        .init("Self.T", is: .conformer(of: .nominal(.init("s", ascii: "SQ")))),
                    ]
                ),
            ]
            {
                if  let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.extension.conditions ..? conditions)
                }
            }
        }
        if  let tests:TestGroup = tests / "external-extension-constraints",
            let colony:SymbolColony = tests.load(colony: """
                TestModules/Symbolgraphs/\
                ExternalExtensionsWithConstraints@\
                ExtendableTypesWithConstraints.symbols.json
                """)
        {
            for (symbol, conditions):(SymbolPath, [GenericConstraint<SymbolIdentifier>]) in
            [
                (
                    "Struct",
                    [
                        .init("T", is: .conformer(of: .nominal(.init("s", ascii: "SQ")))),
                        .init("T", is: .conformer(of: .nominal(.init("s", ascii: "ST")))),
                    ]
                ),
                (
                    "Struct" / "external(_:)",
                    [
                        .init("T", is: .conformer(of: .nominal(.init("s", ascii: "SQ")))),
                        .init("T", is: .conformer(of: .nominal(.init("s", ascii: "ST")))),
                    ]
                ),
                (
                    "Protocol",
                    [
                        .init("Self.T", is: .conformer(of: .nominal(.init("s", ascii: "SQ")))),
                    ]
                ),
                (
                    "Protocol" / "external(_:)",
                    [
                        .init("Self.T", is: .conformer(of: .nominal(.init("s", ascii: "SQ")))),
                    ]
                ),
            ]
            {
                if  let symbol:SymbolDescription = tests.expect(symbol: symbol, in: colony)
                {
                    tests.expect(symbol.extension.conditions ..? conditions)
                }
            }
        }

        if  let tests:TestGroup = tests / "protocols",
            let _:SymbolColony = tests.load(
                colony: "TestModules/Symbolgraphs/Protocols.symbols.json")
        {
        }
        #if !DEBUG
        if  let tests:TestGroup = tests / "stdlib",
            let _:SymbolColony = tests.load(
                colony: "TestModules/Symbolgraphs/Swift.symbols.json")
        {
        }
        #endif
    }
}
