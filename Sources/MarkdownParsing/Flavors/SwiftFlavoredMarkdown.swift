import MarkdownAST

@frozen public
enum SwiftFlavoredMarkdown:MarkdownFlavor
{
    /// Gives anchors to all level 2 and 3 headings.
    @inlinable public static
    func transform(blocks:inout [MarkdownBlock])
    {
        for case let block as MarkdownBlock.Heading in blocks
        {
            if  2 ... 3 ~= block.level
            {
                block.anchor()
            }
        }
    }
}
