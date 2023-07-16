@frozen public
enum UnidocPlane:Int32, Hashable, Equatable, Sendable
{
    case  decl          =  0

    case  module        = -0x80_000000
    case `extension`    = -0x7F_000000
    case  file          = -0x7E_000000
    case  article       = -0x7D_000000

    case  zone          = -0x10_000000
}
extension UnidocPlane:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension UnidocPlane
{
    @inlinable internal static
    func of(_ scalar:Int32) -> Self?
    {
        self.init(rawValue: scalar & -0x01_00000)
    }
    @inlinable public static
    func | (self:Self, significand:Int32) -> Int32
    {
        self.rawValue | significand
    }
}
extension UnidocPlane
{
    @inlinable public static
    func * (significand:Int, self:Self) -> Int32
    {
        precondition(0 ... 0x00_ff_ff_ff ~= significand)
        return self | Int32.init(significand)
    }

    @inlinable public static
    func / (scalar:Int32, self:Self) -> Int?
    {
        self == .of(scalar) ? Int.init(scalar & .significand) : nil
    }
}


