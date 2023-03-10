@frozen public
struct ModuleIdentifier:RawRepresentable, Equatable, Hashable, Sendable
{
    public
    let rawValue:String 

    @inlinable public
    init(rawValue:String)
    {
        self.rawValue = rawValue
    }
}
extension ModuleIdentifier:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool 
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension ModuleIdentifier:ExpressibleByStringLiteral 
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension ModuleIdentifier:CustomStringConvertible
{
    @inlinable public 
    var description:String 
    {
        self.rawValue 
    }
}
