import MarkdownABI
import MarkdownAST
import Snippets
import OrderedCollections

extension Markdown
{
    @frozen public
    struct Snippet<USR>
    {
        public
        let id:Int32

        public
        let caption:[Markdown.BlockElement]
        public
        let slices:OrderedDictionary<String, SnippetSlice<USR>>

        private
        init(id:Int32,
            caption:[Markdown.BlockElement],
            slices:OrderedDictionary<String, SnippetSlice<USR>>)
        {
            self.id = id
            self.caption = caption
            self.slices = slices
        }
    }
}
extension Markdown.Snippet
{
    public
    init(id:Int32,
        caption:String,
        slices:[Markdown.SnippetSlice<USR>],
        using parser:borrowing some Markdown.ParsingEngine)
    {
        let index:OrderedDictionary<String, Markdown.SnippetSlice<USR>> = slices.reduce(
            into: [:])
        {
            $0[$1.id] = $1
        }

        if  caption.allSatisfy(\.isWhitespace)
        {
            self.init(id: id, caption: [], slices: index)
            return
        }

        //  We don’t need to do anything special to the caption, because flavor processing will
        //  be performed after it is inlined into a document.
        let caption:[Markdown.BlockElement] = parser.parse(.init(file: id, text: caption))
        self.init(id: id, caption: caption, slices: index)
    }
}
