import MarkdownAST
import Sources

extension Markdown.Tutorial
{
    /// A `Step` is synonymous with a ``BlockItem``. It takes no arguments and can contain any
    /// ``BlockElement``. It is unclear why Apple invented this directive.
    public final
    class Step:Markdown.BlockContainer<Markdown.BlockElement>
    {
        public
        var source:SourceReference<Markdown.Source>?

        init()
        {
            self.source = nil
            super.init([])
        }

        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.li]
            {
                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.Tutorial.Step:Markdown.BlockDirectiveType
{
    /// Always throws an error, as this directive does not support any options.
    public final
    func configure(option:String, value:String) throws
    {
        throw ArgumentError.unexpected(option)
    }
}
