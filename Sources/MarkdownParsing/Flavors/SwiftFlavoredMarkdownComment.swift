import MarkdownTrees

/// A variant of ``SwiftFlavoredMarkdown`` that clips all headings to a maximum of `h2`.
@frozen public
enum SwiftFlavoredMarkdownComment:MarkdownFlavor
{
    /// Clips `h1` headings to `h2`.
    public static
    func transform(blocks:inout [MarkdownBlock])
    {
        //  Don’t care about nested headings
        for case let heading as MarkdownBlock.Heading in blocks
        {
            heading.clip(to: 2)
        }
    }
}
