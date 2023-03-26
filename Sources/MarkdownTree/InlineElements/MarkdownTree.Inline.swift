extension MarkdownTree
{
    @frozen public
    enum Inline
    {
        case container(InlineContainer<Self>)
        case code(String)
        case html(String)
        case text(String)
    }
}
