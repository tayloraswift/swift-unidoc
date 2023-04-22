import StringIdentifiers

@frozen public
struct ProductIdentifier:StringIdentifier, Equatable, Hashable, Sendable
{
    public
    let description:String 

    @inlinable public
    init(_ description:String)
    {
        self.description = description
    }
}
extension ProductIdentifier:Comparable
{
}
extension ProductIdentifier:ExpressibleByStringLiteral
{
}
