import FNV1
import LexicalPaths
import MarkdownAST
import Symbols
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

        tables.packageLinks["ThisModule", .init(["A"], "b")].append(.init(traits: .init(
                autograph: nil,
                phylum: .func(.instance),
                kinks: [],
                async: false,
                hash: .init(hashing: "x")),
            decl: 0,
            heir: nil,
            documented: true,
            inherited: false,
            id: "x"))

        tables.packageLinks["ThisModule", .init(["A"], "c")].append(.init(traits: .init(
                autograph: nil,
                phylum: .func(.instance),
                kinks: [],
                async: false,
                hash: .init(hashing: "y")),
            decl: 1,
            heir: nil,
            documented: true,
            inherited: false,
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

        tables.packageLinks["OtherModule", .init(["A"], "b")].append(.init(traits: .init(
                autograph: nil,
                phylum: .func(.instance),
                kinks: [],
                async: false,
                hash: .init(hashing: "x")),
            decl: 0,
            heir: nil,
            documented: true,
            inherited: false,
            id: "x"))

        tables.packageLinks["OtherModule", .init(["A"], "c")].append(.init(traits: .init(
                autograph: nil,
                phylum: .func(.instance),
                kinks: [],
                async: false,
                hash: .init(hashing: "y")),
            decl: 1,
            heir: nil,
            documented: true,
            inherited: false,
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

    @Test
    static func SignatureDisambiguation()
    {
        var tables:SSGC.Linker.Tables = .init()

        for (i, (name, (inputs, output))):(Int, (String, ([String], [String]))) in [
            ("f(_:)", (["String"], [])),
            ("f(_:)", (["Int"], [])),
            ("f(_:)", (["String"], ["Int", "Int"])),
            ("f(_:)", (["(Int,[Int?])"], ["String"])),
        ].enumerated()
        {
            let id:Symbol.Decl = .init(.s, ascii: "\(i)")
            tables.packageLinks["ThisModule", .init(["A"], name)].append(.init(traits: .init(
                    autograph: .init(inputs: inputs, output: output),
                    phylum: .func(.instance),
                    kinks: [],
                    async: false,
                    hash: .init(hashing: "\(id)")),
                decl: Int32.init(i),
                heir: nil,
                documented: true,
                inherited: false,
                id: id))
        }

        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: ["A"]))
        {
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:)-((Int,[Int?]))->String"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:)-(String)->(Int,Int)"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:)-(Int)->()"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:)-(String)->()"))))

            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("A.f(_:)->_"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("A.f(_:)->(_,_)"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("A.f(_:)-(Int)"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("A.f(_:)-(String)->()"))))

            #expect($0.outlines() == [
                .vertex(3, text: "f(_:)"),
                .vertex(2, text: "f(_:)"),
                .vertex(1, text: "f(_:)"),
                .vertex(0, text: "f(_:)"),

                .vertex(3, text: "A f(_:)"),
                .vertex(2, text: "A f(_:)"),
                .vertex(1, text: "A f(_:)"),
                .vertex(0, text: "A f(_:)"),
            ])
        }
    }

    @Test
    static func RequirementDisambiguation()
    {
        var tables:SSGC.Linker.Tables = .init()

        for (i, (name, (inputs, output), kinks)):
            (Int, (String, ([String], [String]), Phylum.Decl.Kinks)) in [
            ("f(_:)", (["String"], []), []),
            ("f(_:)", (["String"], []), [.required]),
            ("f(_:)", (["Int"], []), []),
            ("f(_:)", (["Int"], []), [.required]),
        ].enumerated()
        {
            let id:Symbol.Decl = .init(.s, ascii: "\(i)")
            tables.packageLinks["ThisModule", .init(["A"], name)].append(.init(traits: .init(
                    autograph: .init(inputs: inputs, output: output),
                    phylum: .func(.instance),
                    kinks: kinks,
                    async: false,
                    hash: .init(hashing: "\(id)")),
                decl: Int32.init(i),
                heir: nil,
                documented: true,
                inherited: false,
                id: id))
        }

        //  Scoped tests
        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: ["A"]))
        {
            #expect(nil == $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (String) -> () [static func, requirement]"))))
            #expect(nil == $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (String) -> () [static func, requirement: false]"))))

            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (String) -> () [requirement]"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (String) -> () [requirement: false]"))))

            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (Int) -> () [requirement, func]"))))
            #expect(nil != $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (Int) -> () [requirement: false, func]"))))

            #expect(nil == $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (String) -> () [func]"))))
            #expect(nil == $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (String) -> () [func]"))))

            #expect(nil == $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (Int) -> ()"))))
            #expect(nil == $0.outline(reference: .lexical(
                ucf: Self._string("f(_:) (Int) -> ()"))))

            #expect($0.outlines() == [
                .vertex(1, text: "f(_:)"),
                .vertex(0, text: "f(_:)"),
                .vertex(3, text: "f(_:)"),
                .vertex(2, text: "f(_:)"),
            ])
        }
    }
    @Test
    static func Preference()
    {
        var tables:SSGC.Linker.Tables = .init()

        for (i, (name, (documented, inherited), kinks)):
            (Int, (String, (Bool, Bool), Phylum.Decl.Kinks)) in [
            ("f(_:)", (false, false), []),
            ("f(_:)", (false, true), []),

            ("g(_:)", (true, false), []),
            ("g(_:)", (false, false), []),

            //  We should always prefer a symbol that is not inherited, even if it lacks
            //  documentation and the inherited symbol has it.
            ("h(_:)", (true, true), []),
            ("h(_:)", (false, true), []),
            ("h(_:)", (false, false), []),

            //  Inherited symbols with documentation should never cause a conflict.
            ("i(_:)", (true, true), []),
            ("i(_:)", (false, true), []),
            ("i(_:)", (false, false), []),
            ("i(_:)", (true, false), []),

            ("w(_:)", (true, true), []),
            ("w(_:)", (true, true), []),

            ("x(_:)", (true, false), []),
            ("x(_:)", (true, false), []),

            ("y(_:)", (false, false), []),
            ("y(_:)", (false, false), []),

            ("z(_:)", (false, true), []),
            ("z(_:)", (false, true), []),
        ].enumerated()
        {
            let id:Symbol.Decl = .init(.s, ascii: "\(i)")
            tables.packageLinks["ThisModule", .init(["A"], name)].append(.init(traits: .init(
                    autograph: .init(inputs: ["Int"], output: []),
                    phylum: .func(.instance),
                    kinks: kinks,
                    async: false,
                    hash: .init(hashing: "\(id)")),
                decl: Int32.init(i),
                heir: nil,
                documented: documented,
                inherited: inherited,
                id: id))
        }

        tables.resolving(with: .init(origin: nil,
            namespace: nil,
            context: .init(id: "ThisModule"),
            scope: ["A"]))
        {
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("f(_:)"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("g(_:)"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("h(_:)"))))
            #expect(nil != $0.outline(reference: .lexical(ucf: Self._string("i(_:)"))))

            #expect(nil == $0.outline(reference: .lexical(ucf: Self._string("w(_:)"))))
            #expect(nil == $0.outline(reference: .lexical(ucf: Self._string("x(_:)"))))
            #expect(nil == $0.outline(reference: .lexical(ucf: Self._string("y(_:)"))))
            #expect(nil == $0.outline(reference: .lexical(ucf: Self._string("z(_:)"))))

            #expect($0.outlines() == [
                .vertex(0, text: "f(_:)"),
                .vertex(2, text: "g(_:)"),
                .vertex(6, text: "h(_:)"),
                .vertex(10, text: "i(_:)"),
            ])
        }
    }
}
