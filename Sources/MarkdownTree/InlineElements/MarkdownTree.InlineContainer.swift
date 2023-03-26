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
extension MarkdownTree.InlineContainer:MarkdownTextConvertibleElement 
    where Element:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
