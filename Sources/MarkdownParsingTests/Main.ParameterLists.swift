import MarkdownParsing
import MarkdownAST
import Testing

extension Main
{
    struct ParameterLists
    {
    }
}
extension Main.ParameterLists:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let parser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdown> = .init()

        for (shape, source):(String, MarkdownSource) in
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
            let tree:MarkdownTree = .init { parser.parse(source) }
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
}
