import MarkdownAST

@frozen public
enum SwiftFlavoredMarkdown:MarkdownFlavor
{
    /// Does nothing.
    public static
    func transform(blocks _:inout [MarkdownBlock])
    {
    }
}
