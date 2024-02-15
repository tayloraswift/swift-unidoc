import MarkdownABI
import Sources

extension Markdown
{
    @frozen public
    struct InlineContainer<Element> where Element:Markdown.TextElement
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
extension Markdown.InlineContainer:Equatable where Element:Equatable
{
}
extension Markdown.InlineContainer:Hashable where Element:Hashable
{
}
extension Markdown.InlineContainer:Sendable where Element:Sendable
{
}
extension Markdown.InlineContainer:Markdown.TreeElement
{
    public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        let context:Markdown.Bytecode.Context
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
extension Markdown.InlineContainer:Markdown.TextElement
{
    @inlinable public static
    func += (text:inout String, self:Self)
    {
        for element:Element in self.elements
        {
            text += element
        }
    }

    @inlinable public mutating
    func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
    {
        for index:Int in self.elements.indices
        {
            try self.elements[index].outline(by: register)
        }
    }
}
extension Markdown.InlineContainer<Markdown.InlineElement>
{
    /// Returns true if this element list can appear as link text.
    @inlinable internal
    var anchorable:Bool
    {
        for element:Markdown.InlineElement in self.elements
        {
            guard element.anchorable
            else
            {
                return false
            }
        }

        return true
    }
}
