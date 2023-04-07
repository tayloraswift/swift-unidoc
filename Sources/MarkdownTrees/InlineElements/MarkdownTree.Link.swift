import MarkdownABI

extension MarkdownTree
{
    @frozen public
    struct Link
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
extension MarkdownTree.Link:MarkdownElement
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.a, { $0[.href] = self.target }]
        {
            for element:MarkdownTree.Inline in self.elements
            {
                element.emit(into: &$0)
            }
        }
    }
}
extension MarkdownTree.Link:MarkdownText
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
