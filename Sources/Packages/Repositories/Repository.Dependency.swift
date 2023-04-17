extension Repository
{
    @frozen public
    enum Dependency:Equatable, Sendable
    {
        case filesystem(Filesystem)
        case resolvable(Resolvable)
    }
}
