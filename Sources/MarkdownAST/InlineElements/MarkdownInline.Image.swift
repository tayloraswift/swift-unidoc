import MarkdownABI

extension MarkdownInline
{
    @frozen public
    struct Image:Equatable, Hashable, Sendable
    {
        public
        var elements:[MarkdownInline]
        public
        var target:String?
        public
        var title:String?

        @inlinable public
        init(target:String?, title:String? = nil, elements:[MarkdownInline] = [])
        {
            self.elements = elements
            self.target = target
            self.title = title
        }
    }
}
extension MarkdownInline.Image:MarkdownElement
{
    public
    func emit(into binary:inout MarkdownBinaryEncoder)
    {
        binary[.img]
        {
            $0[.alt] = self.alt
            $0[.src] = self.target
            $0[.title] = self.title
        }
    }
}
extension MarkdownInline.Image:MarkdownText
{
    @inlinable public static
    func += (text:inout String, self:Self)
    {
        for element:MarkdownInline in self.elements
        {
            text += element
        }
    }
}
extension MarkdownInline.Image
{
    /// Returns ``text`` if it is not empty.
    @inlinable public
    var alt:String?
    {
        let alt:String = self.text
        return alt.isEmpty ? nil : alt
    }
}
