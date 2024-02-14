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
        /// Emits the elements in this container, with no framing.
        @inlinable open override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            for element:Element in self.elements
            {
                element.emit(into: &binary)
            }
        }

        /// Recursively calls ``Markdown.TreeElement/outline(by:)`` for each element
        /// in this container.
        @inlinable public final override
        func outline(by register:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
            try super.outline(by: register)
            for index:Int in self.elements.indices
            {
                try self.elements[index].outline(by: register)
            }
        }

        /// Visits this container, and then each of its children, if they are block elements.
        @inlinable public final override
        func traverse(_ visit:(Markdown.BlockElement) throws -> ()) rethrows
        {
            try super.traverse(visit)
            for case let element as Markdown.BlockElement in self.elements
            {
                try element.traverse(visit)
            }
        }
    }
}
