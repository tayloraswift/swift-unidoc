import MarkdownABI

extension MarkdownInline
{
    @frozen public
    struct HTML:Equatable, Hashable, Sendable
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
extension MarkdownInline.HTML:MarkdownElement
{
    /// Emits the raw text content of this element in a transparent instruction context.
    public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        binary[.transparent] = self.text
    }
}
