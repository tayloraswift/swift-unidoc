import BSON
import HTML
import MarkdownPluginSwift
import MarkdownRendering
@_spi(testable)
import SymbolGraphBuilder
import SymbolGraphs
import SystemIO
import Testing_

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup) async
    {
        if  let tests:TestGroup = tests / "SplashParsing"
        {
            if  let tests:TestGroup = tests / "LinuxNightly",
                let splash:SSGC.Toolchain.Splash = tests.expect(value: try? .init(parsing: """
                    Swift version 5.8-dev (LLVM 07d14852a049e40, Swift 613b3223d9ec5f6)
                    Target: x86_64-unknown-linux-gnu

                    """))
            {
                tests.expect(splash.swift ==? .init(version: .v(5, 8, 0),
                    nightly: .DEVELOPMENT_SNAPSHOT))
                tests.expect(splash.triple ==? .x86_64_unknown_linux_gnu)
            }
            if  let tests:TestGroup = tests / "Linux",
                let splash:SSGC.Toolchain.Splash = tests.expect(value: try? .init(parsing: """
                    Swift version 5.10 (swift-5.10-RELEASE)
                    Target: x86_64-unknown-linux-gnu

                    """))
            {
                tests.expect(splash.swift ==? .init(version: .v(5, 10, 0), nightly: nil))
                tests.expect(splash.triple ==? .x86_64_unknown_linux_gnu)
            }
            if  let tests:TestGroup = tests / "Xcode",
                let splash:SSGC.Toolchain.Splash = tests.expect(value: try? .init(parsing: """
                    swift-driver version: 1.90.11.1 \
                    Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
                    Target: arm64-apple-macosx14.0

                    """))
            {
                tests.expect(splash.swift ==? .init(version: .v(5, 10, 0), nightly: nil))
                tests.expect(splash.triple ==? .arm64_apple_macosx14_0)
            }
        }

        guard
        let workspace:SSGC.Workspace =
            (tests ! "workspace").do({ try .create(at: ".testing") }),
        let toolchain:SSGC.Toolchain =
            (tests ! "toolchain").do({ try .detect(pretty: true) })
        else
        {
            return
        }

        if  let tests:TestGroup = tests / "standard-library",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.buildStandardLibrary(with: toolchain)
            })
        {
            docs.roundtrip(for: tests)
        }

        #if canImport(IndexStoreDB)

        if  let tests:TestGroup = tests / "swift-snippets"
        {
            tests.do
            {
                let package:SSGC.PackageBuild = .local(
                    project: "TestPackages" / "swift-snippets")

                try workspace.cache.create()

                let (_, sources):(_, SSGC.PackageSources) = try package.compileSwiftPM(
                    with: toolchain)

                let parser:Markdown.SwiftLanguage = .swift(
                    index: try sources.indexStore(for: toolchain))

                guard
                let snippet:SSGC.LazyFile = tests.expect(
                    value: sources.modules.snippets.first(where: { $0.name == "UnitTests" }))
                else
                {
                    return
                }

                let test:SnippetHighlightingTest = .init(parser: parser,
                    source: snippet,
                    slices: [
                        .init(token: "let", color: .keyword),
                        .init(token: " _ = "),
                        .init(token: "Int",
                            color: .type,
                            usr: .init("s:Si")),
                        .init(token: "()"),
                    ],
                    [
                        .init(token: "let", color: .keyword),
                        .init(token: " _:"),
                        .init(token: "String",
                            color: .type,
                            usr: .init("s:SS")),
                        .init(token: " = "),
                        .init(token: "\"",
                            color: .literalString,
                            usr: .init("s:SS19stringInterpolationSSs013DefaultStringB0V_tcfc")),
                        .init(token: "\\("),
                        .init(token: "1959", color: .literalNumber),
                        .init(token: ")"),
                        .init(token: "\"", color: .literalString)
                    ],
                    [
                        .init(token: "let", color: .keyword),
                        .init(token: " _ = "),
                        .init(token: "dictionary", color: .identifier),
                        .init(token: "[",
                            color: nil,
                            usr: .init("s:SDyq_Sgxcip")),
                        .init(token: "\"key\"", color: .literalString),
                        .init(token: "]"),
                    ],
                    [
                        .init(token: "let", color: .keyword),
                        .init(token: " _:"),
                        .init(token: "Key", color: .type),
                        .init(token: " = "),
                        .init(token: "\"key\"", color: .literalString),
                    ])

                try test.run(in: tests)

                let docs:SymbolGraphObject<Void> = try workspace.build(package: package,
                    with: toolchain)

                tests.expect(docs.graph.cultures.count >? 0)
                tests.expect(docs.graph.decls.nodes.count >? 0)

                docs.roundtrip(for: tests)
            }
        }

        #endif

        if  let tests:TestGroup = tests / "Reexportation",
            let _:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(
                    package: .local(project: "TestPackages" / "swift-exportation"),
                    with: toolchain,
                    validation: .failOnErrors)
            })
        {
        }

        group:
        if  let tests:TestGroup = tests / "Local",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(
                    package: .local(project: "TestPackages" / "swift-test"),
                    with: toolchain)
            })
        {
            guard
            let culture:SymbolGraph.Culture = tests.expect(
                value: docs.graph.cultures.first(where: { $0.module.id == "DocCOptions" })),
            let range:ClosedRange<Int32> = tests.expect(
                value: culture.articles)
            else
            {
                break group
            }

            tests.expect(value: culture.article)
            /// `AutomaticSeeAlso` should remain enabled, even though it was disabled
            /// globally, because it is specified locally.
            tests.expect(culture.article?.footer ==? nil)

            if  let headline:Markdown.Bytecode = tests.expect(value: culture.headline)
            {
                tests.expect("\(headline.safe)" ==? """
                    This is a culture root with a custom title.
                    """)
            }

            var a:SymbolGraph.ArticleNode?
            var b:SymbolGraph.ArticleNode?

            for i:Int32 in range
            {
                let node:SymbolGraph.ArticleNode = docs.graph.articles.nodes[i]
                switch docs.graph.articles.symbols[i]
                {
                case .article("DocCOptions", "A"):  a = node
                case .article("DocCOptions", "B"):  b = node
                default:                            continue
                }
            }

            guard
            let a:SymbolGraph.ArticleNode = tests.expect(value: a),
            let b:SymbolGraph.ArticleNode = tests.expect(value: b)
            else
            {
                break group
            }

            tests.expect("\(a.headline.safe)" ==? "A")
            tests.expect("\(b.headline.safe)" ==? "B")

            /// `AutomaticSeeAlso` should be disabled.
            tests.expect(a.article.footer ==? .omit)
            /// `AutomaticSeeAlso` should be disabled, because it was disabled globally in A.
            tests.expect(b.article.footer ==? .omit)
        }
    }
}
