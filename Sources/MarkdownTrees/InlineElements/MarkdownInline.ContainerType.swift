extension MarkdownInline
{
    @frozen public
    enum ContainerType:Hashable, Equatable, Sendable
    {
        case em
        case strong
        case s
    }
}
