import MarkdownParser
import MarkdownTree
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "parameters-list"
        {
            let tree:MarkdownTree =
            """
            -   Parameters:
                -   first: this is the first argument
                -   second:
                    this is the second argument

                -   third:
                    this is the third argument
            """

            if  tests.expect(tree.blocks.count ==? 1),

                let list:MarkdownTree.UnorderedList = tests.expect(
                    value: tree.blocks.first as? MarkdownTree.UnorderedList),

                tests.expect(list.elements.count ==? 1),
                
                let item:MarkdownTree.BlockItem = tests.expect(
                    value: list.elements.first),
                
                tests.expect(item.elements.count ==? 2),

                tests.expect(true: item.elements[0] is MarkdownTree.Paragraph),
                
                let parameters:MarkdownTree.UnorderedList = tests.expect(
                    value: item.elements[1] as? MarkdownTree.UnorderedList),
                
                tests.expect(parameters.elements.count ==? 3)
            {
            }
        }
    }
}
