import MarkdownABI
import Sources

extension Markdown
{
    public final
    class BlockHeading:BlockProse
    {
        public
        let source:SourceReference<Source>?

        public
        var level:Int
        public
        var id:String?

        @inlinable public
        init(source:SourceReference<Source>?,
            level:Int,
            id:String? = nil,
            elements:[InlineElement])
        {
            self.source = source
            self.level = level
            self.id = id

            super.init(elements)
        }

        /// Emits a heading element.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.h(self.level), { $0[.id] = self.id }] { super.emit(into: &$0) }
        }
    }
}
extension Markdown.BlockHeading
{
    /// A convenience initializer for creating a heading containing plain text.
    @inlinable public static
    func h(_ level:Int, text:String) -> Markdown.BlockHeading
    {
        .init(source: nil, level: level, elements: [.text(text)])
    }
}
extension Markdown.BlockHeading
{
    /// Returns the lowercased concatenation of the plain text in the heading.
    @inlinable public
    func signature() -> String
    {
        var signature:String = ""
        for element:Markdown.InlineElement in self.elements
        {
            signature += element.text.lowercased()
        }
        return signature
    }

    /// Promotes the heading by the specified increment, unless that would make it a level 1
    /// heading. (Or if it is already a level 1 heading.)
    @inlinable public
    func promote(by increment:Int = 1)
    {
        self.level = max(self.level - increment, 2)
    }
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
        for element:Markdown.InlineElement in self.elements
        {
            id += element
        }

        self.id = id
    }
}
