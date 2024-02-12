import MarkdownAST

extension Markdown
{
    public
    class BlockDivision:Markdown.BlockContainer<Markdown.BlockElement>
    {
        init()
        {
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
