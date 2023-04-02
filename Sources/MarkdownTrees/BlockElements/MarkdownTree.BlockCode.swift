import MarkdownABI

extension MarkdownTree
{
    public final
    class BlockCode:Block
    {
        public
        var language:String?
        public
        var text:String

        @inlinable public
        init(language:String? = nil, text:String)
        {
            self.language = language
            self.text = text
        }

        /// Emits a `pre` element with a `code` element inside of it.
        public override
        func emit(into binary:inout MarkdownBinary)
        {
            binary[.pre]
            {
                $0[.code, { $0[.language] = self.language }]
                {
                    //  TODO: highlight code
                    $0.write(text: self.text)
                }
            }
        }
    }
}
