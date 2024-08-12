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

            tables.packageLinks["ThisModule", .init(["A"], "b")].append(.init(
                phylum: .func(.instance),
                decl: 0,
                heir: nil,
                hash: .init(hashing: "x"),
                id: "x"))

            tables.packageLinks["ThisModule", .init(["A"], "c")].append(.init(
                phylum: .func(.instance),
                decl: 1,
                heir: nil,
                hash: .init(hashing: "y"),
                id: "y"))

            if  let tests:TestGroup = tests / "Unscoped"
            {
                tables.resolving(with: .init(origin: nil,
                    namespace: nil,
                    context: .init(id: "ThisModule"),
                    scope: []))
                {
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.b"))))
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.c"))))

                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.b"))))
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.c"))))

                    tests.expect($0.outlines() ..? [
                        .vertex(0, text: "A b"),
                        .vertex(1, text: "A c"),
                    ])
                }
            }
            if  let tests:TestGroup = tests / "Scoped"
            {
                tables.resolving(with: .init(origin: nil,
                    namespace: nil,
                    context: .init(id: "ThisModule"),
                    scope: ["A"]))
                {
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.b"))))
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.c"))))

                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("b"))))
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("c"))))

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

            tables.packageLinks["OtherModule", .init(["A"], "b")].append(.init(
                phylum: .func(.instance),
                decl: 0,
                heir: nil,
                hash: .init(hashing: "x"),
                id: "x"))

            tables.packageLinks["OtherModule", .init(["A"], "c")].append(.init(
                phylum: .func(.instance),
                decl: 1,
                heir: nil,
                hash: .init(hashing: "y"),
                id: "y"))

            if  let tests:TestGroup = tests / "Unscoped"
            {
                tables.packageLinks.modules = ["OtherModule", "ThisModule"]
                tables.resolving(with: .init(origin: nil,
                    namespace: nil,
                    context: .init(id: "ThisModule"),
                    scope: []))
                {
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.b"))))
                    tests.expect(value: $0.outline(reference: .lexical(ucf: _string("A.c"))))

                    tests.expect($0.outlines() ..? [
                        .vertex(0, text: "A b"),
                        .vertex(1, text: "A c")
                    ])
                }
            }

            if  let tests:TestGroup = tests / "Invisible"
            {
                tables.packageLinks.modules = []
                tables.resolving(with: .init(origin: nil,
                    namespace: nil,
                    context: .init(id: "ThisModule"),
                    scope: []))
                {
                    tests.expect(nil: $0.outline(reference: .lexical(ucf: _string("A.b"))))
                    tests.expect(nil: $0.outline(reference: .lexical(ucf: _string("A.c"))))

                    tests.expect($0.outlines() ..? [])
                }
            }
        }

        if  let tests:TestGroup = tests / "IntraModuleArticles"
        {
            var tables:SSGC.Linker.Tables = .init()

            tables.articleLinks[.documentation("ThisModule"), "GettingStarted"] = 0
            tables.articleLinks[.tutorials("ThisModule"), "GettingStarted"] = 1
            tables.articleLinks[.tutorials("ThisModule"), "OtherTutorial"] = 2

            tables.resolving(with: .init(origin: nil,
                namespace: nil,
                context: .init(id: "ThisModule"),
                scope: []))
            {

                tests.expect(value: $0.outline(
                    reference: .link(url: _string("OtherTutorial"))))
                tests.expect(value: $0.outline(
                    reference: .link(url: _string("/tutorials/OtherTutorial"))))
                tests.expect(value: $0.outline(
                    reference: .link(url: _string("/tutorials/GettingStarted"))))
                tests.expect(value: $0.outline(
                    reference: .link(url: _string("GettingStarted"))))


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

            tables.articleLinks[.documentation("OtherModule"), "GettingStarted"] = 0
            tables.articleLinks[.tutorials("OtherModule"), "GettingStarted"] = 1
            tables.articleLinks[.tutorials("OtherModule"), "OtherTutorial"] = 2

            tables.resolving(with: .init(origin: nil,
                namespace: nil,
                context: .init(id: "ThisModule"),
                scope: []))
            {

                tests.expect(value: $0.outline(reference: .link(
                    url: _string("//OtherModule/tutorials/OtherModule/OtherTutorial"))))
                tests.expect(value: $0.outline(reference: .link(
                    url: _string("//OtherModule/tutorials/OtherModule/GettingStarted"))))
                tests.expect(value: $0.outline(reference: .link(
                    url: _string("//OtherModule/documentation/OtherModule/GettingStarted"))))


                tests.expect($0.outlines() ..? [
                    .vertex(2, text: "OtherTutorial"),
                    .vertex(1, text: "GettingStarted"),
                    .vertex(0, text: "GettingStarted"),
                ])
            }
        }
    }
}
