import MarkdownABI

extension MarkdownInline
{
    @frozen public
    struct Link
    {
        public
        var elements:[MarkdownInline]
        public
        var target:String?

        @inlinable public
        init(target:String?, elements:[MarkdownInline])
        {
            self.elements = elements
            self.target = target
        }
    }
}
extension MarkdownInline.Link:MarkdownElement
{
    public
    func emit(into binary:inout MarkdownBinaryEncoder)
    {
        binary[.a, { $0[.href] = self.target }]
        {
            for element:MarkdownInline in self.elements
            {
                element.emit(into: &$0)
            }
        }
    }
}
extension MarkdownInline.Link:MarkdownText
{
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
