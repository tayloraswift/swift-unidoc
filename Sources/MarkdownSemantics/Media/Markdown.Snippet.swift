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

        private
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
extension Markdown.Snippet
{
    public
    init(id:Int32,
        caption:String,
        slices:[Markdown.SnippetSlice],
        using parser:borrowing some Markdown.ParsingEngine)
    {
        let index:OrderedDictionary<String, Markdown.SnippetSlice> = slices.reduce(
            into: [:])
        {
            $0[$1.id] = $1
        }

        if  caption.allSatisfy(\.isWhitespace)
        {
            self.init(id: id, caption: [], slices: index)
            return
        }

        //  Most documentation magic is not available to snippet captions (recursive snippets
        //  especially), but we still want the magical aside blocks to work.
        var blocks:[Markdown.BlockElement] = []
        for block:Markdown.BlockElement in parser.parse(.init(file: id, text: caption))
        {
            switch block
            {
            case let list as Markdown.BlockListUnordered:
                var items:[Markdown.BlockItem] = []
                for item:Markdown.BlockItem in list.elements
                {
                    if  let prefix:Markdown.BlockPrefix = .extract(from: &item.elements),
                        case .keywords(let aside) = prefix
                    {
                        blocks.append(aside(item.elements))
                    }
                    else
                    {
                        items.append(item)
                    }
                }
                if !items.isEmpty
                {
                    list.elements = items
                    blocks.append(list)
                }

            case let quote as Markdown.BlockQuote:
                if  case .keywords(let aside) = Markdown.BlockPrefix.extract(
                        from: &quote.elements)
                {
                    blocks.append(aside(quote.elements))
                }
                else
                {
                    blocks.append(quote)
                }

            case let block:
                blocks.append(block)
            }
        }

        self.init(id: id, caption: blocks, slices: index)
    }
}
