import MarkdownAST

/// A variant of ``SwiftFlavoredMarkdown`` that clips all headings to a maximum of `h2`.
@frozen public
enum SwiftFlavoredMarkdownComment:MarkdownFlavor
{
    /// Clips `h1` headings to `h2`.
    public static
    func transform(blocks:inout [Markdown.BlockElement])
    {
        //  Don’t care about nested headings
        for case let heading as Markdown.BlockHeading in blocks
        {
            heading.clip(to: 2)
        }

        //  Anything ``SwiftFlavoredMarkdown`` can do, we can do better
        SwiftFlavoredMarkdown.transform(blocks: &blocks)
    }
}
