import HTML
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import SourceDiagnostics
import Symbols
import Testing

@_spi(testable)
import SymbolGraphLinker

protocol MarkdownTestSuite
{
}
extension MarkdownTestSuite
{
    static func test(
        snippets:[String: Markdown.Snippet] = [:],
        markdown:Markdown.Source,
        expected:String,
        topics:[Int] = []) throws
    {
        let markdownParser:Markdown.Parser<Markdown.SwiftComment> = .init()
        var ignore:Diagnostics<SSGC.Symbolicator> = .init()

        let documentation:Markdown.SemanticDocument = markdown.parse(
            markdownParser: markdownParser,
            snippetsTable: snippets,
            diagnostics: &ignore)

        let overview:MarkdownBinary? = documentation.overview.map
        {
            .init(bytecode: .init(with: $0.emit(into:)))
        }
        let details:MarkdownBinary = .init(bytecode: .init
        {
            (encoder:inout Markdown.BinaryEncoder)in

            documentation.details.emit(into: &encoder)
        })
        let html:HTML = try .init
        {
            try overview?.render(to: &$0)

            $0.append(escaped: 0x0A) // '\n'

            try details.render(to: &$0)
        }

        #expect(html.description == expected)
        #expect(documentation.topics.map(\.items.count) == topics)
    }
}
