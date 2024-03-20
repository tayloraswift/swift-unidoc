extension IP
{
    public
    protocol Address:LosslessStringConvertible, Equatable, Hashable, Sendable
    {
        init?(_ string:some StringProtocol)

        static
        var bitWidth:UInt8 { get }

        static
        func & (a:Self, b:Self) -> Self

        static
        func / (self:Self, bits:UInt8) -> Self
    }
}
