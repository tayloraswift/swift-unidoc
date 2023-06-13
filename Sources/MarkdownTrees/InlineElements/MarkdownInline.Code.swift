import MarkdownABI

extension MarkdownInline
{
    @frozen public
    struct Code
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
extension MarkdownInline.Code:MarkdownElement
{
    public
    func emit(into binary:inout MarkdownBinaryEncoder)
    {
        binary[.code] = self.text
    }
}
extension MarkdownInline.Code:MarkdownText
{
}
