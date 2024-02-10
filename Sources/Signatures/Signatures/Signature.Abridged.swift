import MarkdownABI

extension Signature
{
    @frozen public
    struct Abridged:Equatable, Sendable
    {
        public
        let bytecode:Markdown.Bytecode

        @inlinable public
        init(bytecode:Markdown.Bytecode = [])
        {
            self.bytecode = bytecode
        }
    }
}
