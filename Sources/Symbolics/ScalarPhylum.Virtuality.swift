extension ScalarPhylum
{
    @frozen public
    enum Virtuality:Equatable, Hashable, Comparable, Sendable
    {
        /// Protocol requirement.
        case required
        /// Optional requirement.
        case optional
        /// Open class member.
        case open
    }
}
