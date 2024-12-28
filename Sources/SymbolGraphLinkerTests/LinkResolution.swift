import FNV1
import LexicalPaths
import MarkdownAST
import Testing

@_spi(testable)
import SymbolGraphLinker

@Suite
struct LinkResolution
{
    private
    static let source:Markdown.Source = .init(origin: nil, text: "")

    private
    static func _string(_ string:String) -> Markdown.SourceString
    {
        .init(source: .init(range: nil, in: source), string: string)
    }

    @Test
    static func IntraModule()
    {
        var tables:SSGC.Linker.Tables = .init()

        tables.packageLinks["ThisModule", .init(["A"], "b")].append(.init(
            phylum: .func(.instance),
            decl: 0,
            heir: nil,
            hash: .init(hashing: "x"),
            documented: true,
            autograph: nil,
            id: "x"))

        tables.packageLinks["ThisModule", .init(["A"], "c")].append(.init(
            phylum: .func(.instance),
            decl: 1,
            heir: nil,
            hash: .init(hashing: "y"),
            documented: true,
            autograph: nil,
            id: "y"))

        //  Unscoped tests
        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: []))
        {
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.b"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.c"))))

            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.b"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.c"))))

            #expect($0.outlines() == [
                .vertex(0, text: "A b"),
                .vertex(1, text: "A c"),
            ])
        }
        //  Scoped tests
        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: ["A"]))
        {
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.b"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.c"))))

            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("b"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("c"))))

            #expect($0.outlines() == [
                .vertex(0, text: "A b"),
                .vertex(1, text: "A c"),
                .vertex(0, text: "b"),
                .vertex(1, text: "c"),
            ])
        }
    }

    @Test
    static func CrossModule()
    {
        var tables:SSGC.Linker.Tables = .init()

        tables.packageLinks["OtherModule", .init(["A"], "b")].append(.init(
            phylum: .func(.instance),
            decl: 0,
            heir: nil,
            hash: .init(hashing: "x"),
            documented: true,
            autograph: nil,
            id: "x"))

        tables.packageLinks["OtherModule", .init(["A"], "c")].append(.init(
            phylum: .func(.instance),
            decl: 1,
            heir: nil,
            hash: .init(hashing: "y"),
            documented: true,
            autograph: nil,
            id: "y"))

        //  Without registering modules, these symbols should be invisible to the resolver.
        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: []))
        {
            #expect(nil == $0.outline(reference: .lexical(ucf: Self._string("A.b"))))
            #expect(nil == $0.outline(reference: .lexical(ucf: Self._string("A.c"))))

            #expect($0.outlines() == [])
        }

        tables.packageLinks.register("OtherModule")
        tables.packageLinks.register("ThisModule")

        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: []))
        {
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.b"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("A.c"))))

            #expect($0.outlines() == [
                .vertex(0, text: "A b"),
                .vertex(1, text: "A c")
            ])
        }
    }

    @Test
    static func IntraModuleArticles()
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

            #expect(nil != $0.outline(
                reference: .link(url: Self._string("OtherTutorial"))))
            #expect(nil != $0.outline(
                reference: .link(url: Self._string("/tutorials/OtherTutorial"))))
            #expect(nil != $0.outline(
                reference: .link(url: Self._string("/tutorials/GettingStarted"))))
            #expect(nil != $0.outline(
                reference: .link(url: Self._string("GettingStarted"))))


            #expect($0.outlines() == [
                .vertex(2, text: "OtherTutorial"),
                .vertex(1, text: "GettingStarted"),
                .vertex(0, text: "GettingStarted"),
            ])
        }
    }
    //  https://forums.swift.org/t/you-must-add-the-tutorials-prefix-to-the-path-really/70016/5
    @Test
    static func CrossModuleArticles()
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

            #expect(nil != $0.outline(reference: .link(
                url: Self._string("//OtherModule/tutorials/OtherModule/OtherTutorial"))))
            #expect(nil != $0.outline(reference: .link(
                url: Self._string("//OtherModule/tutorials/OtherModule/GettingStarted"))))
            #expect(nil != $0.outline(reference: .link(
                url: Self._string("//OtherModule/documentation/OtherModule/GettingStarted"))))


            #expect($0.outlines() == [
                .vertex(2, text: "OtherTutorial"),
                .vertex(1, text: "GettingStarted"),
                .vertex(0, text: "GettingStarted"),
            ])
        }
    }
}
