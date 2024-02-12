import MarkdownAST
import Sources

extension Markdown
{
    public
    class BlockDivision:Markdown.BlockContainer<Markdown.BlockElement>
    {
        public
        var source:SourceReference<Markdown.Source>?

        init()
        {
            self.source = nil
            super.init([])
        }
    }
}
extension Markdown.BlockDivision:Markdown.BlockDirectiveType
{
    /// Always throws an error, as this directive does not support any options.
    public final
    func configure(option:String, value:String) throws
    {
        throw ArgumentError.unexpected(option)
    }
}
