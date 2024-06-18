import MarkdownABI

extension SSGC
{
    @frozen @usableFromInline
    enum ArticleType
    {
        case standalone(id:Int32)
        case culture(title:Markdown.Bytecode?)
    }
}
