extension MarkdownTree
{
    public final
    class BlockDirective:BlockContainer<Block>
    {
        public
        var name:String
        public
        var arguments:[(name:String, value:String)]

        @inlinable public
        init(name:String, arguments:[(name:String, value:String)] = [], elements:[Block] = [])
        {
            self.name = name
            self.arguments = arguments
            super.init(elements)
        }
    }
}
