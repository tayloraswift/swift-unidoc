extension Markdown
{
    @frozen public
    enum InlineContainerType:Equatable, Hashable, Sendable
    {
        case em
        case strong
        case s
    }
}
