@frozen public
struct ModuleIdentifier:StringBackedIdentifier, RawRepresentable, Equatable, Hashable, Sendable
{
    public
    let rawValue:String 

    @inlinable public
    init(rawValue:String)
    {
        self.rawValue = rawValue
    }
}
extension ModuleIdentifier:Comparable, ExpressibleByStringLiteral, CustomStringConvertible
{
}
