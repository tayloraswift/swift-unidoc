import MarkdownABI

extension MarkdownTree
{
    @frozen public
    struct InlineLink
    {
        public
        var elements:[Inline]
        public
        var target:String?

        @inlinable public
        init(target:String?, elements:[Inline])
        {
            self.elements = elements
            self.target = target
        }
    }
}
extension MarkdownTree.InlineLink:MarkdownBinaryConvertibleElement
{
    @inlinable public
    func serialize(into binary:inout MarkdownBinary)
    {
        binary[.a, { $0[.href] = self.target }]
        {
            for element:MarkdownTree.Inline in self.elements
            {
                element.serialize(into: &$0)
            }
        }
    }
}
extension MarkdownTree.InlineLink:MarkdownTextConvertibleElement
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
