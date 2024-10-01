extension UCF.Selector
{
    @frozen public
    enum Seal:Equatable, Hashable, Sendable
    {
        case trailingParentheses
        case trailingArguments
    }
}
