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
extension MarkdownTree.Link:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
