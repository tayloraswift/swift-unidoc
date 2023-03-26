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
    }
}
