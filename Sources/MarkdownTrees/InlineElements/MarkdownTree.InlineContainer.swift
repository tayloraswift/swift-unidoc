import MarkdownABI

extension MarkdownTree
{
    @frozen public
    struct InlineContainer<Element> where Element:MarkdownText
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
extension MarkdownTree.InlineContainer:MarkdownElement
{
    @inlinable public mutating
    func outline(by register:(_ symbol:String) throws -> UInt32?) rethrows
    {
        for index:Int in self.elements.indices
        {
            try self.elements[index].outline(by: register)
        }
    }
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
extension MarkdownTree.InlineContainer:MarkdownText
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
