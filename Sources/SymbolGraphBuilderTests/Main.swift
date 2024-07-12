import BSON
import HTML
import MarkdownPluginSwift
import MarkdownRendering
@_spi(testable)
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import System
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
                let swift:SSGC.Toolchain = tests.expect(value: try? .init(parsing: """
                    Swift version 5.8-dev (LLVM 07d14852a049e40, Swift 613b3223d9ec5f6)
                    Target: x86_64-unknown-linux-gnu

                    """))
            {
                tests.expect(swift.version ==? .init(version: .v(5, 8, 0),
                    nightly: .DEVELOPMENT_SNAPSHOT))
                tests.expect(swift.triple ==? .init("x86_64", "unknown", "linux", "gnu"))
            }
            if  let tests:TestGroup = tests / "Linux",
                let swift:SSGC.Toolchain = tests.expect(value: try? .init(parsing: """
                    Swift version 5.10 (swift-5.10-RELEASE)
                    Target: x86_64-unknown-linux-gnu

                    """))
            {
                tests.expect(swift.version ==? .init(version: .v(5, 10, 0), nightly: nil))
                tests.expect(swift.triple ==? .init("x86_64", "unknown", "linux", "gnu"))
            }
            if  let tests:TestGroup = tests / "Xcode",
                let swift:SSGC.Toolchain = tests.expect(value: try? .init(parsing: """
                    swift-driver version: 1.90.11.1 \
                    Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
                    Target: arm64-apple-macosx14.0

                    """))
            {
                tests.expect(swift.version ==? .init(version: .v(5, 10, 0), nightly: nil))
                tests.expect(swift.triple ==? .init("arm64", "apple", "macosx14.0", nil))
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
                try workspace.build(special: .swift, with: toolchain)
            })
        {
            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        #if canImport(IndexStoreDB)

        if  let tests:TestGroup = tests / "swift-snippets"
        {
            tests.do
            {
                let package:SSGC.PackageBuild = .local(
                    project: "swift-snippets",
                    among: "TestPackages")

                try workspace.artifacts.create()

                let (_, sources):(_, SSGC.PackageSources) = try package.compileSwiftPM(
                    into: workspace.artifacts,
                    with: toolchain)

                let parser:Markdown.SwiftLanguage = .swift(
                    index: try sources.indexStore(for: toolchain))

                guard
                let snippet:SSGC.LazyFile = tests.expect(
                    value: sources.snippets.first(where: { $0.name == "UnitTests" }))
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

                docs.roundtrip(for: tests, in: workspace.artifacts)
            }
        }

        #endif

        group:
        if  let tests:TestGroup = tests / "Local",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: .local(
                        project: "swift-test",
                        among: "TestPackages"),
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

        if  let tests:TestGroup = tests / "swift-atomics",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-atomics",
                        from: "https://github.com/apple/swift-atomics.git",
                        at: "1.1.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.decls.nodes.count >? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  https://github.com/tayloraswift/swift-unidoc/issues/211
        #if !os(macOS)
        if  let tests:TestGroup = tests / "swift-nio",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-nio",
                        from: "https://github.com/apple/swift-nio.git",
                        at: "2.65.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            //  the swift-docc-plugin dependency should have been linted.
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [
                "swift-atomics",
                "swift-collections",
                //  swift-nio grew a dependency on swift-system in 2.63.0
                "swift-system",
            ])

            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.decls.nodes.count >? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }
        #endif

        //  SwiftNIO has lots of dependencies. If we can handle SwiftNIO,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-nio-ssl",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-nio-ssl",
                        from: "https://github.com/apple/swift-nio-ssl.git",
                        at: "2.24.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.decls.nodes.count >? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  The swift-async-dns-resolver repo includes a git submodule, so we should be able
        //  to handle that.
        if  let tests:TestGroup = tests / "swift-async-dns-resolver",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-async-dns-resolver",
                        from: "https://github.com/apple/swift-async-dns-resolver.git",
                        at: "0.1.2",
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.decls.nodes.count >? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  SwiftSyntax is a morbidly obese package. If we can handle SwiftSyntax,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-syntax",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-syntax",
                        from: "https://github.com/apple/swift-syntax.git",
                        at: "508.0.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            //  the swift-argument-parser dependency should have been linted.
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [])

            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.decls.nodes.count >? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  The swift-snapshot-testing package at 1.17.0 has a dependency on SwiftSyntax with
        //  prerelease bounds on both sides, so we should be able to handle that.
        if  let tests:TestGroup = tests / "swift-snapshot-testing",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-snapshot-testing",
                        from: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                        at: "1.17.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [
                "swift-syntax",
            ])

            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.decls.nodes.count >? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  IndexstoreDB links the LLVM Blocks runtime, so this tests that we handle that.
        //  Since it involves specifying the location of the Swift runtime, we can only expect
        //  this to work within a particular Docker container.
        #if false
        if  let tests:TestGroup = tests / "indexstore-db",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "indexstore-db",
                        from: "https://github.com/apple/indexstore-db.git",
                        at: "swift-5.10-RELEASE",
                        in: workspace,
                        flags: .init(cxx: ["-I/usr/lib/swift", "-I/usr/lib/swift/Block"])),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [])

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }
        #endif

        if  let tests:TestGroup = tests / "TSPL",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        project: "swift-book",
                        from: "https://github.com/apple/swift-book.git",
                        at: "swift-5.10-fcs",
                        as: .book,
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.graph.cultures.count >? 0)
            tests.expect(docs.graph.articles.nodes.count >? 0)
            tests.expect(docs.graph.decls.nodes.count ==? 0)

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }
    }
}
