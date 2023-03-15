@frozen public
struct TargetIdentifier:StringBackedIdentifier, RawRepresentable, Equatable, Hashable, Sendable
{
    public
    let rawValue:String 

    @inlinable public
    init(rawValue:String)
    {
        self.rawValue = rawValue
    }
}
extension TargetIdentifier:Comparable, ExpressibleByStringLiteral, CustomStringConvertible
{
}
