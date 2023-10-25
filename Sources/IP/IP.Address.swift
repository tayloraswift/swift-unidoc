extension IP
{
    /// A native SwiftNIO ``IPv4Address`` is reference counted and resilient, and we
    /// would rather pass around an inline value type.
    @frozen public
    enum Address:Equatable, Hashable, Sendable
    {
        case v4(V4)
        case v6(V6)
    }
}
extension IP.Address:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case let .v4(v4):   v4.description
        case let .v6(v6):   v6.description
        }
    }
}
extension IP.Address
{
    @inlinable public static
    func v4(_ string:some StringProtocol) -> Self?
    {
        if let v4:IP.V4 = .init(string) { .v4(v4) } else { nil }
    }

    @inlinable public static
    func v6(_ string:some StringProtocol) -> Self?
    {
        if let v6:IP.V6 = .init(string) { .v6(v6) } else { nil }
    }
}
