import MarkdownParsing
import MarkdownTrees
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "parameters-list"
        {
            for (shape, tree):(String, MarkdownTree) in
            [
                (
                    "tight",
                    """
                    -   Parameters:
                        -   first: this is the first argument
                        -   second: this is the second argument
                        -   third: this is the third argument
                    """
                ),
                (
                    "mixed",
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
                    "complex",
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
                if  let tests:TestGroup = tests / shape,

                    tests.expect(tree.blocks.count ==? 1),

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
}
