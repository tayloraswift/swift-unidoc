import MarkdownTrees

extension StaticLinker.Article
{
    struct Standalone
    {
        let id:Int32
        let title:MarkdownBlock.Heading

        init(id:Int32, title:MarkdownBlock.Heading)
        {
            self.id = id
            self.title = title
        }
    }
}
