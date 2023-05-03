@frozen public
enum ScalarVirtuality:Equatable, Hashable, Comparable, Sendable
{
    /// Protocol requirement.
    case required
    /// Optional requirement.
    case optional
    /// Open class member.
    case open
}
