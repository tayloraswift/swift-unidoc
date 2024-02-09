import MarkdownABI

extension Snippet
{
    @frozen public
    struct Slice:Equatable, Sendable
    {
        public
        let id:String
        public
        let bytecode:MarkdownBytecode

        @inlinable public
        init(id:String, bytecode:MarkdownBytecode)
        {
            self.id = id
            self.bytecode = bytecode
        }
    }
}
