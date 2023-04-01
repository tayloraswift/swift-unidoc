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
        /// Serializes the elements in this container, with no framing.
        public override
        func serialize(into binary:inout MarkdownBinary)
        {
            for element:Element in self.elements
            {
                element.serialize(into: &binary)
            }
        }
    }
}
