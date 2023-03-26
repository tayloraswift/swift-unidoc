extension MarkdownTree
{
    @frozen public
    enum InlineBlock
    {
        case container(InlineContainer<Self>)
        case code(String)
        case html(String)
        case image(Image)
        case link(Link)
        case symbol(String)
        case text(String)
    }
}
