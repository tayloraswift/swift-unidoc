import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Sources
import Testing

@Suite
struct Parsing
{
    private
    static var parser:Markdown.Parser<Markdown.SwiftFlavor> { .init() }

    @Test(arguments: [
            "doc:GettingStarted",
            "doc:Getting%20Started",
            "doc:BarbieCore/Getting%20Started",
        ])
    static func Doclinks(_ expected:String) throws
    {
        let source:Markdown.Source = .init(origin: nil, text: "<\(expected)>")
        let tree:Markdown.Tree = .init { Self.parser.parse(source) }

        let paragraph:Markdown.BlockParagraph = try #require(
            tree.blocks.first as? Markdown.BlockParagraph)
        let autolink:Markdown.InlineAutolink = try #require(
            {
                switch $0
                {
                case .autolink(let autolink):   autolink
                case _:                         nil
                }
            } (paragraph.elements.first))

        #expect(!autolink.code)
        #expect(autolink.text.string == expected)
    }

    @Test(arguments: [
            """
            -   Parameters:
                -   first: this is the first argument
                -   second: this is the second argument
                -   third: this is the third argument
            """,
            """
            -   Parameters:
                -   first: this is the first argument
                -   second:
                    this is the second argument

                -   third:
                    this is the third argument
            """,
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
            """,
        ] as [Markdown.Source])
    static func ParameterLists(_ source:Markdown.Source) throws
    {
        let tree:Markdown.Tree = .init { Self.parser.parse(source) }

        #expect(tree.blocks.count == 1)

        let list:Markdown.BlockListUnordered = try #require(
            tree.blocks.first as? Markdown.BlockListUnordered)

        #expect(list.elements.count == 1)

        let item:Markdown.BlockItem = try #require(list.elements.first)

        #expect(item.elements.count == 2)

        #expect(item.elements[0] is Markdown.BlockParagraph)

        let parameters:Markdown.BlockListUnordered = try #require(
            item.elements[1] as? Markdown.BlockListUnordered)

        #expect(parameters.elements.count == 3)
    }

    @Test(arguments: [
            (
                """
                ``x``
                """,
                (0, 2)
            ),
            (
                """
                abc ``x``
                """,
                (0, 6)
            ),
            (
                """
                abc
                def ``x``
                """,
                (1, 6)
            ),
        ])
    static func SourcePositions(_ source:Markdown.Source,
        _ expected:(line:Int, column:Int)) throws
    {
        let tree:Markdown.Tree = .init { Self.parser.parse(source) }
        let expected:SourcePosition = try #require(.init(
            line: expected.line,
            column: expected.column))
        let paragraph:Markdown.BlockParagraph = try #require(
            tree.blocks.first as? Markdown.BlockParagraph)

        var position:SourcePosition?
        for element:Markdown.InlineElement in paragraph.elements
        {
            if case .autolink(let autolink) = element
            {
                position = autolink.source.range?.lowerBound
                break
            }
        }

        #expect(position == expected)
    }
}
