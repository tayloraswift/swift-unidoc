import MarkdownABI
import MarkdownRendering
@_spi(testable) import SymbolGraphBuilder
import SymbolGraphs
import SystemIO
import Testing

@Suite(.serialized) struct SymbolGraphBuilderTests {
    private let workspace: SSGC.Workspace
    private let toolchain: SSGC.Toolchain

    init() throws {
        self.workspace = try .create(at: ".testing")
        self.toolchain = try .detect(pretty: true)

        print(
            """
            note: \
            using toolchain '\(self.toolchain.splash.swift)' (\(self.toolchain.splash.triple))
            """
        )
    }

    @Test func StandardLibrary() throws {
        let docs: SymbolGraphObject<Void> = try self.workspace.buildStandardLibrary(
            with: self.toolchain
        )
        try docs.roundtrip()
    }

    @Test func PackageWithReexports() throws {
        let docs: SymbolGraphObject<Void> = try self.workspace.build(
            package: .local(project: "TestPackages" / "swift-exportation"),
            with: toolchain,
            validation: .failOnErrors
        )
        try docs.roundtrip()
    }

    @Test func PackageWithArticles() throws {
        let docs: SymbolGraphObject<Void> = try self.workspace.build(
            package: .local(project: "TestPackages" / "swift-test"),
            with: toolchain
        )
        try docs.roundtrip()
        let culture: SymbolGraph.Culture = try #require(
            docs.graph.cultures.first { $0.module.id == "DocCOptions" }
        )
        let range: ClosedRange<Int32> = try #require(culture.articles)
        let headline: Markdown.Bytecode = try #require(culture.headline)

        #expect(culture.article != nil)
        /// `AutomaticSeeAlso` should remain enabled, even though it was disabled
        /// globally, because it is specified locally.
        #expect(culture.article?.footer == nil)
        #expect("\(headline.safe)" == "This is a culture root with a custom title.")

        var article: (a: SymbolGraph.ArticleNode?, b: SymbolGraph.ArticleNode?) = (nil, nil)
        for i: Int32 in range {
            let node: SymbolGraph.ArticleNode = docs.graph.articles.nodes[i]
            switch docs.graph.articles.symbols[i] {
            case .article("DocCOptions", "A"):  article.a = node
            case .article("DocCOptions", "B"):  article.b = node
            default:                            continue
            }
        }

        let a: SymbolGraph.ArticleNode = try #require(article.a)
        let b: SymbolGraph.ArticleNode = try #require(article.b)

        #expect("\(a.headline.safe)" == "A")
        #expect("\(b.headline.safe)" == "B")

        /// `AutomaticSeeAlso` should be disabled.
        #expect(a.article.footer == .omit)
        /// `AutomaticSeeAlso` should be disabled, because it was disabled globally in A.
        #expect(b.article.footer == .omit)
    }

    @Test func SnippetHighlighting() throws {
        #if !canImport(IndexStoreDB)
        // closure literal to suppress “will never be executed” warning
        if ({ true }()) {
            print("note: skipping snippet highlighting tests due to missing IndexStoreDB")
            return
        }
        #endif

        let package: SSGC.PackageBuild = .local(
            project: "TestPackages" / "swift-snippets"
        )

        try workspace.cache.create()

        let (_, sources): (_, SSGC.PackageSources) = try package.compileSwiftPM(
            with: toolchain
        )

        let parser: Markdown.SwiftLanguage = .swift(
            index: try sources.indexStore(for: toolchain)
        )

        let snippet: SSGC.LazyFile = try #require(
            sources.modules.snippets.first { $0.name == "UnitTests" }
        )

        try parser.test(
            source: snippet,
            slices: [
                .init(token: "let", color: .keyword),
                .init(token: " _ = "),
                .init(
                    token: "Int",
                    color: .type,
                    usr: .init("s:Si")
                ),
                .init(token: "()"),
            ],
            [
                .init(token: "let", color: .keyword),
                .init(token: " _: "),
                .init(
                    token: "String",
                    color: .type,
                    usr: .init("s:SS")
                ),
                .init(token: " = "),
                .init(
                    token: "\"",
                    color: .literalString,
                    usr: .init("s:s26DefaultStringInterpolationV13appendLiteralyySSF")
                ),
                .init(token: "\\("),
                .init(token: "1959", color: .literalNumber),
                .init(token: ")"),
                .init(
                    token: "\"",
                    color: .literalString,
                    usr: .init("s:s26DefaultStringInterpolationV13appendLiteralyySSF")
                )
            ],
            [
                .init(token: "let", color: .keyword),
                .init(token: " _ = "),
                .init(token: "dictionary", color: .identifier),
                .init(
                    token: "[",
                    color: nil,
                    usr: .init("s:SDyq_Sgxcip")
                ),
                .init(token: "\"key\"", color: .literalString),
                .init(token: "]"),
            ],
            [
                .init(token: "let", color: .keyword),
                .init(token: " _: "),
                .init(token: "Key", color: .type),
                .init(token: " = "),
                .init(token: "\"key\"", color: .literalString),
            ]
        )

        let docs: SymbolGraphObject<Void> = try workspace.build(
            package: package,
            with: toolchain
        )

        #expect(docs.graph.cultures.count > 0)
        #expect(docs.graph.decls.nodes.count > 0)

        try docs.roundtrip()
    }
}
