import MarkdownABI

extension MarkdownTree
{
    @frozen public
    struct Image
    {
        public
        var elements:[Inline]
        public
        var target:String?
        public
        var title:String?

        @inlinable public
        init(target:String?, title:String? = nil, elements:[Inline] = [])
        {
            self.elements = elements
            self.target = target
            self.title = title
        }
    }
}
extension MarkdownTree.Image:MarkdownElement
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.img]
        {
            $0[.alt] = self.alt
            $0[.src] = self.target
            $0[.title] = self.title
        }
    }
}
extension MarkdownTree.Image:MarkdownText
{
    /// Returns ``text`` if it is not empty.
    @inlinable public
    var alt:String?
    {
        let alt:String = self.text
        return alt.isEmpty ? nil : alt
    }
    @inlinable public
    var text:String
    {
        self.elements.lazy.map(\.text).joined()
    }
}
