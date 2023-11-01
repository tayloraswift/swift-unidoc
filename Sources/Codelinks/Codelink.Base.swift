extension Codelink
{
    @frozen public
    enum Base:Equatable, Hashable, Sendable
    {
        case qualified
        case relative
    }
}
