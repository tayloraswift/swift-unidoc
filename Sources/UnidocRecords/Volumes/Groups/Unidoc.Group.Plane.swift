extension Unidoc.Group
{
    /// Tag bits for ``Unidoc.Group.ID``.
    @frozen public
    enum Plane:UInt32, Hashable, Equatable, Sendable
    {
        case  polygon       = 0xC0_000000
        case `extension`    = 0xC2_000000
        case  topic         = 0xC3_000000
    }
}
extension Unidoc.Group.Plane
{
    @inlinable internal static
    func of(_ scalar:Int32) -> Self?
    {
        self.init(rawValue: .init(bitPattern: scalar) & 0xFF_000000)
    }

    @inlinable internal static
    func | (self:Self, significand:Int32) -> Int32
    {
        .init(bitPattern: self.rawValue) | significand
    }

    @inlinable public static
    func * (significand:Int, self:Self) -> Int32
    {
        precondition(0 ... 0x00_ff_ff_ff ~= significand)
        return self | Int32.init(significand)
    }
}
