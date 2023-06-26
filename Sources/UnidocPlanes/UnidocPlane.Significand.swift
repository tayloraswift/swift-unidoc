extension UnidocPlane
{
    @frozen public
    enum Significand:Hashable, Equatable, Sendable
    {
        case significand
    }
}
extension UnidocPlane.Significand
{
    @inlinable public static
    func & (scalar:Int32, self:Self) -> Int32
    {
        scalar & 0x00_FFFFFF
    }
}
