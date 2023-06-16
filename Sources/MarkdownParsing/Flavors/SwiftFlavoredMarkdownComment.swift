import MarkdownTrees

/// A variant of ``SwiftFlavoredMarkdown`` that demotes all headings by one level.
public
enum SwiftFlavoredMarkdownComment:MarkdownFlavor
{
    public static
    func parse(_ string:String, id:Int) -> [MarkdownBlock]
    {
        let blocks:[MarkdownBlock] = SwiftFlavoredMarkdown.parse(string, id: id)
        //  Don’t care about nested headings
        for case let heading as MarkdownBlock.Heading in blocks
        {
            heading.demote()
        }
        return blocks
    }
}
