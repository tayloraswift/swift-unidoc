import MarkdownABI
import Sources

extension Markdown
{
    open
    class BlockContainer<Element>:BlockElement where Element:Markdown.TreeElement
    {
        public final
        var elements:[Element]

        @inlinable public
        init(_ elements:[Element])
        {
            self.elements = elements
        }

        /// Recursively calls ``Markdown.TreeElement/outline(by:)`` for each element
        /// in this container.
        public final override
        func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
            for index:Int in self.elements.indices
            {
                try self.elements[index].outline(by: register)
            }
        }
        /// Emits the elements in this container, with no framing.
        open override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            for element:Element in self.elements
            {
                element.emit(into: &binary)
            }
        }
    }
}
