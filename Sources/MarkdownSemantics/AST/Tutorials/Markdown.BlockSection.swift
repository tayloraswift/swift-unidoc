import MarkdownAST
import Sources

extension Markdown
{
    /// A `BlockSection` is our abstraction for the multitude of (redundant) section-like Apple
    /// directives. It renders as a `<section>` element and includes an automatically generated
    /// `<h2>` element containing the section `title`, if present. The `<h2>` element has
    /// a clickable anchor.
    public
    class BlockSection:BlockContainer<BlockElement>
    {
        public
        var source:SourceReference<Source>?

        var title:String?

        init()
        {
            self.source = nil
            self.title = nil
            super.init([])
        }

        class
        var titleDefault:String? { nil }

        public final override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.section]
            {
                let title:String? = self.title ?? Self.titleDefault

                $0[.h2] { $0[.id] = title } = title

                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.BlockSection:Markdown.BlockDirectiveType
{
    public final
    func configure(option:String, value:Markdown.SourceString) throws
    {
        switch option
        {
        case "title", "name":
            break
        case let option:
            throw ArgumentError.unexpected(option)
        }

        guard case nil = self.title
        else
        {
            throw ArgumentError.duplicated(option)
        }

        self.title = value.string
    }
}
