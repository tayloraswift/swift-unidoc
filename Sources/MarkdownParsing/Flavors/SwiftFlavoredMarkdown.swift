import Markdown
import MarkdownTrees

public
enum SwiftFlavoredMarkdown:MarkdownFlavor
{
    public static
    func parse(_ string:String, id:Int) -> [MarkdownBlock]
    {
        let document:Document = .init(parsing: string, options:
        [
            .parseBlockDirectives,
            .parseSymbolLinks,
        ])
        return document.blockChildren.map { MarkdownBlock.create(from: $0, in: id) }
    }
}
