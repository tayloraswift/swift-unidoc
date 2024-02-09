import MarkdownAST

@frozen public
enum SwiftFlavoredMarkdown:MarkdownFlavor
{
    /// Gives anchors to all level 2 and 3 headings.
    @inlinable public static
    func transform(blocks:inout [Markdown.BlockElement])
    {
        for case let block as Markdown.BlockHeading in blocks
        {
            if  2 ... 3 ~= block.level
            {
                block.anchor()
            }
        }
    }
}
