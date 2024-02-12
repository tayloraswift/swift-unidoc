import MarkdownAST
import Sources

extension Markdown
{
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
