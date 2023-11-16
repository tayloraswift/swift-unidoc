import MarkdownAST

@frozen public
enum SwiftFlavoredMarkdown:MarkdownFlavor
{
    /// Does nothing.
    @inlinable public static
    func transform(blocks _:inout [MarkdownBlock])
    {
    }
}
