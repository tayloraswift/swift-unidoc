import MarkdownABI
import MarkdownAST
import Snippets
import OrderedCollections

extension Markdown
{
    @frozen public
    struct Snippet
    {
        public
        let id:Int32

        public
        let caption:[Markdown.BlockElement]
        public
        let slices:OrderedDictionary<String, SnippetSlice>

        @inlinable public
        init(id:Int32,
            caption:[Markdown.BlockElement],
            slices:OrderedDictionary<String, SnippetSlice>)
        {
            self.id = id
            self.caption = caption
            self.slices = slices
        }
    }
}
