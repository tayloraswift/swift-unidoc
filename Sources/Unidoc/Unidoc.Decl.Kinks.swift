extension Unidoc.Decl
{
    @frozen public
    struct Kinks:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        var bits:UInt8

        @inlinable internal
        init(bits:UInt8)
        {
            self.bits = bits
        }
    }
}
extension Unidoc.Decl.Kinks:RawRepresentable
{
    @inlinable public
    var rawValue:UInt8 { self.bits }
    @inlinable public
    init?(rawValue:UInt8)
    {
        self.init(bits: rawValue)
    }
}
extension Unidoc.Decl.Kinks:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Unidoc.Decl.Kink...)
    {
        self.init(bits: 0)
        for what:Unidoc.Decl.Kink in arrayLiteral
        {
            self[is: what] = true
        }
    }
}
extension Unidoc.Decl.Kinks
{
    @inlinable public static
    func + (lhs:Self, rhs:Self) -> Self
    {
        .init(bits: lhs.bits | rhs.bits)
    }

    @inlinable public static
    func += (self:inout Self, other:Self)
    {
        self.bits |= other.bits
    }

    @inlinable public
    subscript(is kink:Unidoc.Decl.Kink) -> Bool
    {
        get
        {
            self.bits & kink.rawValue != 0
        }
        set(set)
        {
            set ?
            (self.bits |=  kink.rawValue) :
            (self.bits &= ~kink.rawValue)
        }
    }
}
