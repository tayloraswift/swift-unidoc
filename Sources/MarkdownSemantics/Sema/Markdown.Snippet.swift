import MarkdownABI
import MarkdownAST
import Snippets
import Symbols
import OrderedCollections

extension Markdown
{
    @frozen public
    struct Snippet
    {
        public
        let id:Int32

        private
        let captionParser:any Markdown.ParsingEngine
        private
        let captionSource:Markdown.Source?

        public
        let slices:OrderedDictionary<String, SnippetSlice<Symbol.USR>>

        private
        init(id:Int32,
            captionParser:any Markdown.ParsingEngine,
            captionSource:Markdown.Source?,
            slices:OrderedDictionary<String, SnippetSlice<Symbol.USR>>)
        {
            self.id = id
            self.captionParser = captionParser
            self.captionSource = captionSource
            self.slices = slices
        }
    }
}
extension Markdown.Snippet
{
    public
    init(id:Int32,
        captionParser:any Markdown.ParsingEngine,
        caption:String,
        slices:[Markdown.SnippetSlice<Symbol.USR>])
    {
        let index:OrderedDictionary<String, Markdown.SnippetSlice<Symbol.USR>> = slices.reduce(
            into: [:])
        {
            $0[$1.id] = $1
        }

        self.init(id: id,
            captionParser: captionParser,
            captionSource: caption.allSatisfy(\.isWhitespace) ? nil : .init(file: id,
                text: caption),
            slices: index)
    }

    /// Parses the Snippet’s caption and returns the resulting block elements.
    ///
    /// Snippets must be re-parsed every time they are inlined into a document, to account for
    /// the possibility that the same caption may be embedded multiple times.
    func caption() -> [Markdown.BlockElement]
    {
        //  We don’t need to do anything special to the caption, because flavor processing will
        //  be performed after it is inlined into a document.
        self.captionSource.map(self.captionParser.parse(_:)) ?? []
    }
}
