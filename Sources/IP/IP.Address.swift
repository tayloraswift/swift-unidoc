extension IP
{
    public
    typealias Address = _IPAddress
}

/// The real name of this protocol is ``IP.Address``.
public
protocol _IPAddress:LosslessStringConvertible, Equatable, Hashable, Sendable
{
    init?(_ string:some StringProtocol)

    static
    var bitWidth:UInt8 { get }

    static
    func & (a:Self, b:Self) -> Self

    static
    func / (self:Self, bits:UInt8) -> Self
}
