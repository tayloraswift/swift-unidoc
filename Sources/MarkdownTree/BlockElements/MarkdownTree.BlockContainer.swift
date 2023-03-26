extension MarkdownTree
{
    public
    class BlockContainer<Element>:Block
    {
        public final
        var elements:[Element]

        @inlinable public
        init(_ elements:[Element])
        {
            self.elements = elements
        }
    }
}
