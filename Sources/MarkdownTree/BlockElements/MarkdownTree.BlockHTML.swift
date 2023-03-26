extension MarkdownTree
{
    public final
    class BlockHTML:Block
    {
        public
        var text:String

        @inlinable public
        init(text:String)
        {
            self.text = text
        }
    }
}
