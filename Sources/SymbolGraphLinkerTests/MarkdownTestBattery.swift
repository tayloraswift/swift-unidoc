import HTML
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Testing
import UnidocDiagnostics

@_spi(testable)
import SymbolGraphLinker

protocol MarkdownTestBattery:TestBattery
{
}
extension MarkdownTestBattery
{
    static
    func run(tests:TestGroup, markdown:MarkdownSource, expected:String, topics:[Int] = [])
    {
        let markdownParser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdownComment> = .init()
        var ignore:DiagnosticContext<StaticSymbolicator> = .init()

        tests.do
        {
            let documentation:Markdown.SemanticDocument = markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore)

            let overview:MarkdownBinary? = documentation.overview.map
            {
                .init(bytecode: .init(with: $0.emit(into:)))
            }
            let details:MarkdownBinary = .init(bytecode: .init
            {
                (encoder:inout Markdown.BinaryEncoder)in

                documentation.details.visit
                {
                    $0.emit(into: &encoder)
                }
            })
            let html:HTML = try .init
            {
                try overview?.render(to: &$0)

                $0.append(escaped: 0x0A) // '\n'

                try details.render(to: &$0)
            }

            tests.expect(html.description ==? expected)

            if  let tests:TestGroup = tests / "Topics"
            {
                tests.expect(documentation.topics.map(\.members.count) ..? topics)
            }
        }
    }
}
