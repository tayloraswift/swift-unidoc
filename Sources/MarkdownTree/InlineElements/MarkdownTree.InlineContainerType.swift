extension MarkdownTree
{
    @frozen public
    enum InlineContainerType:Hashable, Equatable, Sendable
    {
        case em
        case strong
        case s
    }
}
