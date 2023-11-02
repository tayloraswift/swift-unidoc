import MarkdownABI
import Sources

extension MarkdownBlock
{
    open
    class Container<Element>:MarkdownBlock where Element:MarkdownElement
    {
        public final
        var elements:[Element]

        @inlinable public
        init(_ elements:[Element])
        {
            self.elements = elements
        }

        /// Recursively calls ``MarkdownElement/outline(by:)`` for each element
        /// in this container.
        public final override
        func outline(by register:(MarkdownInline.Autolink) throws -> Int?) rethrows
        {
            for index:Int in self.elements.indices
            {
                try self.elements[index].outline(by: register)
            }
        }
        /// Emits the elements in this container, with no framing.
        open override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            for element:Element in self.elements
            {
                element.emit(into: &binary)
            }
        }
    }
}
