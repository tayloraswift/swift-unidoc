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
extension MarkdownTree.InlineCode:MarkdownElement
{
    public
    func emit(into binary:inout MarkdownBinaryEncoder)
    {
        binary[.code] = self.text
    }
}
extension MarkdownTree.InlineCode:MarkdownText
{
}
