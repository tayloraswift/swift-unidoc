extension Markdown.BlockCodeReference
{
    @frozen public
    enum DiffBase:Equatable, Sendable
    {
        case auto
        case file(String)
    }
}
