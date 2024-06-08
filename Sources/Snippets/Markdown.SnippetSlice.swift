import MarkdownABI

extension Markdown
{
    @frozen public
    struct SnippetSlice<USR>
    {
        public
        let id:String
        public
        let line:Int
        public
        let utf8:[UInt8]
        public
        let code:[SnippetFragment<USR>]

        @inlinable public
        init(id:String, line:Int, utf8:[UInt8], code:[SnippetFragment<USR>])
        {
            self.id = id
            self.line = line
            self.utf8 = utf8
            self.code = code
        }
    }
}
