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
extension MarkdownTree.InlineContainer:MarkdownTextConvertibleElement 
    where Element:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
extension MarkdownTree.InlineContainer:MarkdownBinaryConvertibleElement
    where Element:MarkdownBinaryConvertibleElement
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        let context:MarkdownBytecode.Context
        switch self.type
        {
        case .em:       context = .em
        case .s:        context = .s
        case .strong:   context = .strong
        }
        binary[context]
        {
            for element:Element in self.elements
            {
                element.emit(into: &$0)
            }
        }
    }
}
