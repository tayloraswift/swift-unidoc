import MarkdownAST
import Sources

extension Markdown
{
    /// A `BlockSection` is our abstraction for the multitude of (redundant) section-like Apple
    /// directives. It renders as a `<section>` element and includes an automatically generated
    /// `<h2>` element containing the section ``title``, if present. The `<h2>` element has
    /// a clickable anchor.
    public
    class BlockSection:Markdown.BlockContainer<Markdown.BlockElement>
    {
        public
        var source:SourceReference<Markdown.Source>?

        private(set)
        var title:String?

        init()
        {
            self.source = nil
            self.title = nil
            super.init([])
        }

        public final override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.section]
            {
                $0[.h2] { $0[.id] = self.title } = self.title

                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.BlockSection:Markdown.BlockDirectiveType
{
    public final
    func configure(option:String, value:String) throws
    {
        guard case "title" = option
        else
        {
            throw ArgumentError.unexpected(option)
        }
        guard case nil = self.title
        else
        {
            throw ArgumentError.duplicated(option)
        }

        self.title = value
    }
}
