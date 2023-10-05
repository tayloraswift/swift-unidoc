extension Volume
{
    @frozen public
    enum Citizenship:UInt8, Equatable, Hashable, Sendable
    {
        /// Something originates from the same culture as something else.
        case culture = 0x01
        /// Something originates from the same package as something else.
        case package = 0x02
        /// Something originates from a different package than something else.
        case foreign = 0x03
    }
}
extension Volume.Citizenship:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
