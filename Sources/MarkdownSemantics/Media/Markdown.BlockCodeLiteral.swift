import MarkdownABI

extension Markdown
{
    /// A `BlockCodeLiteral` is like a ``BlockCode``, but it contains code that has already been
    /// highlighted and compiled to bytecode.
    final
    class BlockCodeLiteral:BlockElement
    {
        private
        let bytecode:Markdown.Bytecode
        private
        let language:String

        init(bytecode:Markdown.Bytecode, language:String = "swift")
        {
            self.bytecode = bytecode
            self.language = language
        }

        override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.snippet, { $0[.language] = self.language }]
            {
                $0 += self.bytecode
            }
        }
    }
}
