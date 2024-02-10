import MarkdownABI

extension Markdown
{
    @frozen public
    struct SnippetSlice:Equatable, Sendable
    {
        public
        let id:String
        public
        let line:Int
        public
        let code:Markdown.Bytecode

        @inlinable public
        init(id:String, line:Int, code:Markdown.Bytecode)
        {
            self.id = id
            self.line = line
            self.code = code
        }
    }
}
