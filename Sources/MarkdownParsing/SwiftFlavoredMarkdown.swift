import Markdown
import MarkdownTrees

public
enum SwiftFlavoredMarkdown:MarkdownFlavor
{
    public static
    func parse(_ string:String) -> [MarkdownTree.Block]
    {
        let document:Document = .init(parsing: string, options:
        [
            .parseBlockDirectives,
            .parseSymbolLinks,
        ])
        return document.blockChildren.map(MarkdownTree.Block.create(from:))
    }
}
