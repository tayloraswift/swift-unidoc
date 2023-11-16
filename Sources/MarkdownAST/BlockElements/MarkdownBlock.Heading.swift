import MarkdownABI

extension MarkdownBlock
{
    public final
    class Heading:Container<MarkdownInline.Block>
    {
        public
        var level:Int
        public
        var id:String?

        @inlinable public
        init(level:Int, id:String? = nil, elements:[MarkdownInline.Block])
        {
            self.level = level
            self.id = id

            super.init(elements)
        }

        /// Emits a heading element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.h(self.level), { $0[.id] = self.id }] { super.emit(into: &$0) }
        }
    }
}
extension MarkdownBlock.Heading
{
    /// Clips the heading to the specified maximum level. For example, if `level` is 3, then
    /// this function will demote `h1` and `h2` headings to `h3`, but it will leave `h3` and
    /// `h4` headings alone. This function will never demote headings beyond `h6`.
    @inlinable public
    func clip(to level:Int)
    {
        self.level = min(max(self.level, level), 6)
    }

    /// Adds an ``id`` to the heading if it does not already have one and it only contains
    /// anchorable elements. The identifier is **not** percent-encoded.
    @inlinable public
    func anchor()
    {
        guard
        case nil = self.id,
        self.elements.allSatisfy(\.anchorable)
        else
        {
            return
        }

        var id:String = ""
        for element:MarkdownInline.Block in self.elements
        {
            id += element
        }

        self.id = id
    }
}
