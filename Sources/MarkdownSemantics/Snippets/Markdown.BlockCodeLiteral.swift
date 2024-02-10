import MarkdownABI

extension Markdown
{
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
