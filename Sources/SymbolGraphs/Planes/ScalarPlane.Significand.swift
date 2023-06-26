extension ScalarPlane
{
    @frozen public
    enum Significand:Hashable, Equatable, Sendable
    {
        case significand
    }
}
extension ScalarPlane.Significand
{
    @inlinable public static
    func & (scalar:Int32, self:Self) -> Int32
    {
        scalar & 0x00_FFFFFF
    }
}
