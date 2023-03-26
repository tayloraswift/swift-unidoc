extension MarkdownTree
{
    @frozen public
    struct Image
    {
        public
        var elements:[Inline]
        public
        var target:String?
        public
        var title:String?

        @inlinable public
        init(target:String?, title:String? = nil, elements:[Inline] = [])
        {
            self.elements = elements
            self.target = target
            self.title = title
        }
    }
}
