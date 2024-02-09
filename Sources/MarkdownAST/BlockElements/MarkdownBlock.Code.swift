import MarkdownABI

extension MarkdownBlock
{
    public final
    class Code<Language>:MarkdownBlock where Language:Markdown.CodeLanguageType
    {
        public
        var language:Language?
        public
        var text:String

        @inlinable public
        init(language:Language? = nil, text:String)
        {
            self.language = language
            self.text = text
        }

        /// Emits a `pre` element with a `code` element inside of it.
        @inlinable public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.snippet, { $0[.language] = self.language?.name }]
            {
                if  case nil = self.language?.highlighter.emit(self.text,
                        into: &$0)
                {
                    Markdown.PlainText.Highlighter.none.emit(self.text,
                        into: &$0)
                }
            }
        }
    }
}
