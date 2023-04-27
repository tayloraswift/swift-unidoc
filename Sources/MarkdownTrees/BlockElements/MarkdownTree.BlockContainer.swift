import MarkdownABI

extension MarkdownTree
{
    open
    class BlockContainer<Element>:Block where Element:MarkdownElement
    {
        public final
        var elements:[Element]

        @inlinable public
        init(_ elements:[Element])
        {
            self.elements = elements
        }

        /// Recursively calls ``MarkdownElement outline(by:)`` for each element
        /// in this container.
        public final override
        func outline(by register:(_ symbol:String) throws -> UInt32?) rethrows
        {
            for index:Int in self.elements.indices
            {
                try self.elements[index].outline(by: register)
            }
        }
        /// Emits the elements in this container, with no framing.
        open override
        func emit(into binary:inout MarkdownBinary)
        {
            for element:Element in self.elements
            {
                element.emit(into: &binary)
            }
        }
    }
}
