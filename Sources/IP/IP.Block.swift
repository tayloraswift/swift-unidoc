extension IP
{
    /// A representation of a CIDR block.
    @frozen public
    struct Block<Base>:Equatable, Hashable, Sendable where Base:IP.Address
    {
        public
        var base:Base
        public
        var bits:UInt8

        @inlinable public
        init(base:Base, bits:UInt8)
        {
            self.base = base
            self.bits = bits
        }
    }
}
extension IP.Block<IP.V6>
{
    /// Converts the IPv4 base address to an IPv6 address and adds 96 to the prefix length.
    @inlinable public
    init(v4:IP.Block<IP.V4>)
    {
        self.init(base: .init(v4: v4.base), bits: v4.bits + 96)
    }
}
extension IP.Block:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.base)/\(self.bits)" }
}
extension IP.Block:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        guard
        let slash:String.Index = string.lastIndex(of: "/"),
        let bits:UInt8 = .init(string[string.index(after: slash)...]),
            0 ... Base.bitWidth ~= bits,
        let base:Base = .init(string[..<slash]),
            base == base / bits
        else
        {
            return nil
        }

        self.init(base: base, bits: bits)
    }
}
