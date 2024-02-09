import MarkdownABI

extension Snippet
{
    @frozen public
    struct Slice:Equatable, Sendable
    {
        public
        let id:String
        public
        let bytecode:Markdown.Bytecode

        @inlinable public
        init(id:String, bytecode:Markdown.Bytecode)
        {
            self.id = id
            self.bytecode = bytecode
        }
    }
}
