import MarkdownParsing
import MarkdownAST
import Sources
import Testing

extension Main
{
    struct SourcePositions
    {
    }
}
extension Main.SourcePositions:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let parser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdown> = .init()
        for (name, source, expected):(String, MarkdownSource, (line:Int, column:Int)) in
        [
            (
                "ZeroZero",
                """
                ``x``
                """,
                (0, 2)
            ),
            (
                "Prefixed",
                """
                abc ``x``
                """,
                (0, 6)
            ),
            (
                "Multiline",
                """
                abc
                def ``x``
                """,
                (1, 6)
            ),
        ]
        {
            let tree:MarkdownTree = .init { parser.parse(source) }
            if  let tests:TestGroup = tests / name,
                let expected:SourcePosition = tests.expect(value: .init(
                    line: expected.line,
                    column: expected.column)),
                let paragraph:MarkdownBlock.Paragraph = tests.expect(
                    value: tree.blocks.first as? MarkdownBlock.Paragraph)
            {
                var position:SourcePosition?
                for element:MarkdownInline.Block in paragraph.elements
                {
                    if case .autolink(let autolink) = element
                    {
                        position = autolink.source.range?.lowerBound
                        break
                    }
                }
                if  let position:SourcePosition = tests.expect(value: position)
                {
                    tests.expect(position ==? expected)
                }
            }
        }
    }
}
