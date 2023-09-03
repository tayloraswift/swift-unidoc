import MarkdownParsing
import MarkdownAST
import Sources
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "ParameterLists"
        {
            for (shape, string):(String, String) in
            [
                (
                    "Tight",
                    """
                    -   Parameters:
                        -   first: this is the first argument
                        -   second: this is the second argument
                        -   third: this is the third argument
                    """
                ),
                (
                    "Mixed",
                    """
                    -   Parameters:
                        -   first: this is the first argument
                        -   second:
                            this is the second argument

                        -   third:
                            this is the third argument
                    """
                ),
                (
                    "Complex",
                    """
                    -   Parameters:
                        -   first:
                            this is the first argument
                        -   second:
                            this is the second argument
                            - do this
                            - but don’t do this

                        -   third:
                            this is the third argument
                    """
                ),
            ]
            {
                let tree:MarkdownTree = .init(parsing: string,
                    with: SwiftFlavoredMarkdownParser.init(),
                    as: SwiftFlavoredMarkdown.self)
                if  let tests:TestGroup = tests / shape,

                    tests.expect(tree.blocks.count ==? 1),

                    let list:MarkdownBlock.UnorderedList = tests.expect(
                        value: tree.blocks.first as? MarkdownBlock.UnorderedList),

                    tests.expect(list.elements.count ==? 1),

                    let item:MarkdownBlock.Item = tests.expect(
                        value: list.elements.first),

                    tests.expect(item.elements.count ==? 2),

                    tests.expect(true: item.elements[0] is MarkdownBlock.Paragraph),

                    let parameters:MarkdownBlock.UnorderedList = tests.expect(
                        value: item.elements[1] as? MarkdownBlock.UnorderedList),

                    tests.expect(parameters.elements.count ==? 3)
                {
                }
            }
        }
        if  let tests:TestGroup = tests / "Doclinks"
        {
            for (name, string, expected):(String, String, String) in
            [
                (
                    "Basic",
                    "<doc:GettingStarted>",
                    "GettingStarted"
                ),
                (
                    "PercentEncoded",
                    "<doc:Getting%20Started>",
                    "Getting%20Started"
                ),
                (
                    "Qualified",
                    "<doc:BarbieCore/Getting%20Started>",
                    "BarbieCore/Getting%20Started"
                ),
            ]
            {
                let tree:MarkdownTree = .init(parsing: string,
                    with: SwiftFlavoredMarkdownParser.init(),
                    as: SwiftFlavoredMarkdown.self)
                if  let tests:TestGroup = tests / name,
                    let paragraph:MarkdownBlock.Paragraph = tests.expect(
                        value: tree.blocks.first as? MarkdownBlock.Paragraph),
                    let autolink:MarkdownInline.Autolink = tests.expect(
                        value:
                        {
                            switch $0
                            {
                            case .autolink(let autolink):   return autolink
                            case _:                         return nil
                            }
                        } (paragraph.elements.first))
                {
                    tests.expect(false: autolink.code)
                    tests.expect(autolink.text ==? expected)
                }
            }
        }
        if  let tests:TestGroup = tests / "SourcePositions"
        {
            for (name, string, expected):(String, String, (line:Int, column:Int)) in
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
                let tree:MarkdownTree = .init(parsing: string,
                    with: SwiftFlavoredMarkdownParser.init(),
                    as: SwiftFlavoredMarkdown.self)
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
                            position = autolink.source?.range.lowerBound
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
}
