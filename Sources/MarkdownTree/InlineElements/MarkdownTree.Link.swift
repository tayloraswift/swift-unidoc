extension MarkdownTree
{
    @frozen public
    struct Link
    {
        public
        var elements:[Inline]
        public
        var target:String?

        @inlinable public
        init(target:String?, elements:[Inline])
        {
            self.elements = elements
            self.target = target
        }
    }
}
