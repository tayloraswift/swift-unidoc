import MarkdownABI

extension Declaration.Fragments
{
    @frozen public
    struct Abridged:Equatable, Sendable
    {
        public
        let bytecode:MarkdownBytecode

        @inlinable public
        init(bytecode:MarkdownBytecode = [])
        {
            self.bytecode = bytecode
        }
    }
}
