extension MarkdownInline
{
    @frozen public
    enum ContainerType:Equatable, Hashable, Sendable
    {
        case em
        case strong
        case s
    }
}
