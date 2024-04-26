import FNV1
import LexicalPaths
import MarkdownAST
@_spi(testable)
import SymbolGraphLinker
import Testing_

extension Main
{
    enum LinkResolution
    {
    }
}
extension Main.LinkResolution:TestBattery
{
    static
    func run(tests:TestGroup) throws
    {
        let source:Markdown.Source = .init(origin: nil, text: "")

        func _string(_ string:String) -> Markdown.SourceString
        {
            .init(source: .init(range: nil, in: source), string: string)
        }

        if  let tests:TestGroup = tests / "IntraModule"
        {
            var tables:SSGC.Linker.Tables = .init()

            tables.codelinks["ThisModule", .init(["A"], "b")].overload(
                with: .init(target: .scalar(0),
                    phylum: .func(.instance),
                    hash: .init(hashing: "x")))

            tables.codelinks["ThisModule", .init(["A"], "c")].overload(
                with: .init(target: .scalar(1),
                    phylum: .func(.instance),
                    hash: .init(hashing: "y")))

            if  let tests:TestGroup = tests / "Unscoped"
            {
                tables.resolving(with: .init(
                    namespace: nil,
                    culture: .init(
                        resources: [:],
                        imports: [],
                        module: "ThisModule"),
                    origin: nil,
                    scope: []))
                {
                    tests.expect(value: $0.outline(reference: .code(_string("A.b"))))
                    tests.expect(value: $0.outline(reference: .code(_string("A.c"))))

                    tests.expect(value: $0.outline(reference: .code(_string("A.b"))))
                    tests.expect(value: $0.outline(reference: .code(_string("A.c"))))

                    tests.expect($0.outlines() ..? [
                        .vertex(0, text: "A b"),
                        .vertex(1, text: "A c"),
                    ])
                }
            }
            if  let tests:TestGroup = tests / "Scoped"
            {
                tables.resolving(with: .init(
                    namespace: nil,
                    culture: .init(
                        resources: [:],
                        imports: [],
                        module: "ThisModule"),
                    origin: nil,
                    scope: ["A"]))
                {
                    tests.expect(value: $0.outline(reference: .code(_string("A.b"))))
                    tests.expect(value: $0.outline(reference: .code(_string("A.c"))))

                    tests.expect(value: $0.outline(reference: .code(_string("b"))))
                    tests.expect(value: $0.outline(reference: .code(_string("c"))))

                    tests.expect($0.outlines() ..? [
                        .vertex(0, text: "A b"),
                        .vertex(1, text: "A c"),
                        .vertex(0, text: "b"),
                        .vertex(1, text: "c"),
                    ])
                }
            }
        }

        if  let tests:TestGroup = tests / "CrossModule"
        {
            var tables:SSGC.Linker.Tables = .init()

            tables.codelinks["OtherModule", .init(["A"], "b")].overload(
                with: .init(target: .scalar(0),
                    phylum: .func(.instance),
                    hash: .init(hashing: "x")))

            tables.codelinks["OtherModule", .init(["A"], "c")].overload(
                with: .init(target: .scalar(1),
                    phylum: .func(.instance),
                    hash: .init(hashing: "y")))

            if  let tests:TestGroup = tests / "Unscoped"
            {
                tables.resolving(with: .init(
                    namespace: nil,
                    culture: .init(
                        resources: [:],
                        imports: ["OtherModule"],
                        module: "ThisModule"),
                    origin: nil,
                    scope: []))
                {
                    tests.expect(value: $0.outline(reference: .code(_string("A.b"))))
                    tests.expect(value: $0.outline(reference: .code(_string("A.c"))))

                    tests.expect($0.outlines() ..? [
                        .vertex(0, text: "A b"),
                        .vertex(1, text: "A c")
                    ])
                }
            }

            if  let tests:TestGroup = tests / "Invisible"
            {
                tables.resolving(with: .init(
                    namespace: nil,
                    culture: .init(
                        resources: [:],
                        imports: [],
                        module: "ThisModule"),
                    origin: nil,
                    scope: []))
                {
                    tests.expect(value: $0.outline(reference: .code(_string("A.b"))))
                    tests.expect(value: $0.outline(reference: .code(_string("A.c"))))

                    tests.expect($0.outlines() ..? [
                        .unresolved(ucf: "A.b", location: nil),
                        .unresolved(ucf: "A.c", location: nil)
                    ])
                }
            }
        }

        if  let tests:TestGroup = tests / "IntraModuleArticles"
        {
            var tables:SSGC.Linker.Tables = .init()

            tables.doclinks[.documentation("ThisModule"), "GettingStarted"] = 0
            tables.doclinks[.tutorials("ThisModule"), "GettingStarted"] = 1
            tables.doclinks[.tutorials("ThisModule"), "OtherTutorial"] = 2

            tables.resolving(with: .init(
                namespace: nil,
                culture: .init(
                    resources: [:],
                    imports: [],
                    module: "ThisModule"),
                origin: nil,
                scope: []))
            {

                tests.expect(value: $0.outline(
                    reference: .link(_string("OtherTutorial"))))
                tests.expect(value: $0.outline(
                    reference: .link(_string("/tutorials/OtherTutorial"))))
                tests.expect(value: $0.outline(
                    reference: .link(_string("/tutorials/GettingStarted"))))
                tests.expect(value: $0.outline(
                    reference: .link(_string("GettingStarted"))))


                tests.expect($0.outlines() ..? [
                    .vertex(2, text: "OtherTutorial"),
                    .vertex(1, text: "GettingStarted"),
                    .vertex(0, text: "GettingStarted"),
                ])
            }
        }
        //  https://forums.swift.org/t/you-must-add-the-tutorials-prefix-to-the-path-really/70016/5
        if  let tests:TestGroup = tests / "CrossModuleArticles"
        {
            var tables:SSGC.Linker.Tables = .init()

            tables.doclinks[.documentation("OtherModule"), "GettingStarted"] = 0
            tables.doclinks[.tutorials("OtherModule"), "GettingStarted"] = 1
            tables.doclinks[.tutorials("OtherModule"), "OtherTutorial"] = 2

            tables.resolving(with: .init(
                namespace: nil,
                culture: .init(
                    resources: [:],
                    imports: ["OtherModule"],
                    module: "ThisModule"),
                origin: nil,
                scope: []))
            {

                tests.expect(value: $0.outline(reference: .link(_string(
                    "//OtherModule/tutorials/OtherModule/OtherTutorial"))))
                tests.expect(value: $0.outline(reference: .link(_string(
                    "//OtherModule/tutorials/OtherModule/GettingStarted"))))
                tests.expect(value: $0.outline(reference: .link(_string(
                    "//OtherModule/documentation/OtherModule/GettingStarted"))))


                tests.expect($0.outlines() ..? [
                    .vertex(2, text: "OtherTutorial"),
                    .vertex(1, text: "GettingStarted"),
                    .vertex(0, text: "GettingStarted"),
                ])
            }
        }
    }
}
