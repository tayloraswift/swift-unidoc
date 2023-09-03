extension MarkdownBlock
{
    public final
    class Directive:Container<MarkdownBlock>
    {
        public
        var name:String
        public
        var arguments:[(name:String, value:String)]

        @inlinable public
        init(name:String,
            arguments:[(name:String, value:String)] = [],
            elements:[MarkdownBlock] = [])
        {
            self.name = name
            self.arguments = arguments
            super.init(elements)
        }
    }
}
