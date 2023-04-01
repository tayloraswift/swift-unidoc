import MarkdownABI

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
extension MarkdownTree.InlineContainer:MarkdownBinaryConvertibleElement
    where Element:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func serialize(into binary:inout MarkdownBinary)
    {
        let type:MarkdownBinary.ContainerType
        switch self.type
        {
        case .em:       type = .em
        case .s:        type = .s
        case .strong:   type = .strong
        }
        binary[type]
        {
            for element:Element in self.elements
            {
                element.serialize(into: &$0)
            }
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
