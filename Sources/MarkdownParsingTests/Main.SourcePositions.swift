import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Sources
import Testing_

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
        let parser:Markdown.Parser<Markdown.SwiftFlavor> = .init()
        for (name, source, expected):(String, Markdown.Source, (line:Int, column:Int)) in
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
            let tree:Markdown.Tree = .init { parser.parse(source) }
            if  let tests:TestGroup = tests / name,
                let expected:SourcePosition = tests.expect(value: .init(
                    line: expected.line,
                    column: expected.column)),
                let paragraph:Markdown.BlockParagraph = tests.expect(
                    value: tree.blocks.first as? Markdown.BlockParagraph)
            {
                var position:SourcePosition?
                for element:Markdown.InlineElement in paragraph.elements
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
