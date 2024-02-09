import MarkdownABI
import Sources

extension MarkdownInline
{
    @frozen public
    struct Container<Element> where Element:MarkdownText
    {
        public
        var elements:[Element]
        public
        var type:ContainerType

        @inlinable public
        init(_ type:ContainerType, elements:[Element])
        {
            self.type = type
            self.elements = elements
        }
    }
}
extension MarkdownInline.Container:Equatable where Element:Equatable
{
}
extension MarkdownInline.Container:Hashable where Element:Hashable
{
}
extension MarkdownInline.Container:Sendable where Element:Sendable
{
}
extension MarkdownInline.Container:MarkdownElement
{
    @inlinable public mutating
    func outline(by register:(MarkdownInline.Autolink) throws -> Int?) rethrows
    {
        for index:Int in self.elements.indices
        {
            try self.elements[index].outline(by: register)
        }
    }
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
extension MarkdownInline.Container:MarkdownText
{
    @inlinable public static
    func += (text:inout String, self:Self)
    {
        for element:Element in self.elements
        {
            text += element
        }
    }
}
extension MarkdownInline.Container<MarkdownInline.Block>
{
    /// Returns true if this element list can appear as link text.
    @inlinable internal
    var anchorable:Bool
    {
        for element:MarkdownInline.Block in self.elements
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
