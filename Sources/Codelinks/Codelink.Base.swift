extension CodelinkV4
{
    @frozen public
    enum Base:Equatable, Hashable, Sendable
    {
        case qualified
        case relative
    }
}
