extension SymbolGraph
{
    @frozen public
    enum Plane:UInt32, Hashable, Equatable, Sendable
    {
        case  module        = 0x00_000000
        case  decl          = 0x01_000000

        case  article       = 0x80_000000
        case  file          = 0x81_000000

        //  Used to identify groups in the Unidoc database; never appear in a symbol graph.
        case  autogroup     = 0xC0_000000
        case `extension`    = 0xC2_000000
        case  topic         = 0xC3_000000

        case  foreign       = 0xFE_000000
        case  global        = 0xFF_000000
    }
}
extension SymbolGraph.Plane:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension SymbolGraph.Plane
{
    @inlinable public
    func contains(_ scalar:Int32) -> Bool
    {
        self.rawValue == .init(bitPattern: scalar) & 0xFF_000000
    }

    @inlinable public static
    func of(_ scalar:Int32) -> Self?
    {
        self.init(rawValue: .init(bitPattern: scalar) & 0xFF_000000)
    }

    @inlinable public static
    func | (self:Self, significand:Int32) -> Int32
    {
        .init(bitPattern: self.rawValue) | significand
    }
}
extension SymbolGraph.Plane
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
