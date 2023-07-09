@frozen public
struct MinorVersion:VectorVersion, Equatable, Hashable, Comparable, Sendable
{
    public
    var components:Components

    @inlinable public
    init(components:Components)
    {
        self.components = components
    }
}
extension MinorVersion
{
    @inlinable public static
    func v(_ major:UInt16, _ minor:UInt16) -> Self
    {
        self.init(components: .init(major: major, minor: minor))
    }
}
