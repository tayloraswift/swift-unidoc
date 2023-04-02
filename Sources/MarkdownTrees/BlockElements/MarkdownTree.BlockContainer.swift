import MarkdownABI

extension MarkdownTree
{
    public
    class BlockContainer<Element>:Block where Element:MarkdownBinaryConvertibleElement
    {
        public final
        var elements:[Element]

        @inlinable public
        init(_ elements:[Element])
        {
            self.elements = elements
        }
        /// Emits the elements in this container, with no framing.
        public override
        func emit(into binary:inout MarkdownBinary)
        {
            for element:Element in self.elements
            {
                element.emit(into: &binary)
            }
        }
    }
}
