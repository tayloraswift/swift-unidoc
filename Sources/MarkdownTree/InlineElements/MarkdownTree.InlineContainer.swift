extension MarkdownTree
{
    @frozen public
    struct InlineContainer<Element>
    {
        public
        var elements:[Element]
        public
        var type:InlineContainerType

        @inlinable public
        init(_ type:InlineContainerType, elements:[Element])
        {
            self.type = type
            self.elements = elements
        }
    }
}
