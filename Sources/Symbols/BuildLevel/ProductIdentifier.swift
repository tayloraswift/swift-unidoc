@frozen public
struct ProductIdentifier:StringBackedIdentifier, RawRepresentable, Equatable, Hashable, Sendable
{
    public
    let rawValue:String 

    @inlinable public
    init(rawValue:String)
    {
        self.rawValue = rawValue
    }
}
extension ProductIdentifier:Comparable, ExpressibleByStringLiteral, CustomStringConvertible
{
}
