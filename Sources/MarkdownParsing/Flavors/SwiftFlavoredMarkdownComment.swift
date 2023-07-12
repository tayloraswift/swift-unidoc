import MarkdownTrees

/// A variant of ``SwiftFlavoredMarkdown`` that demotes all headings by one level.
@frozen public
enum SwiftFlavoredMarkdownComment:MarkdownFlavor
{
    /// Demotes all headings by one level.
    public static
    func transform(blocks:inout [MarkdownBlock])
    {
        //  Don’t care about nested headings
        for case let heading as MarkdownBlock.Heading in blocks
        {
            heading.demote()
        }
    }
}
