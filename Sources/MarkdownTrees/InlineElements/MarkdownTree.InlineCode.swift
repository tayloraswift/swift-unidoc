import MarkdownABI

extension MarkdownTree
{
    @frozen public
    struct InlineCode
    {
        public
        var text:String

        @inlinable public
        init(text:String)
        {
            self.text = text
        }
    }
}
extension MarkdownTree.InlineCode:MarkdownTextConvertibleElement
{
}
extension MarkdownTree.InlineCode:MarkdownBinaryConvertibleElement
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.code] = self.text
    }
}
