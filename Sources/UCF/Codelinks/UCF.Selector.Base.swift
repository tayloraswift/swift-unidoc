extension UCF.Selector
{
    @frozen public
    enum Base:Equatable, Hashable, Sendable
    {
        case qualified
        case relative
    }
}
