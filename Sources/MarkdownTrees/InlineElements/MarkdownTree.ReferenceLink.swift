import MarkdownABI

extension MarkdownTree
{
    @frozen public
    struct ReferenceLink
    {
        public
        var elements:[Inline]
        public
        var target:UInt32

        @inlinable public
        init(target:UInt32, elements:[Inline])
        {
            self.elements = elements
            self.target = target
        }
    }
}
extension MarkdownTree.ReferenceLink:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func serialize(into binary:inout MarkdownBinary)
    {
        binary[.a, { $0.reference(self.target) }]
        {
            for element:MarkdownTree.Inline in self.elements
            {
                element.serialize(into: &$0)
            }
        }
    }
}
extension MarkdownTree.ReferenceLink:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
