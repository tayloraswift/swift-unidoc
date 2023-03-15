public
protocol StringBackedIdentifier:RawRepresentable<String>
{
    init(rawValue:String)
}
extension StringBackedIdentifier where Self:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool 
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension StringBackedIdentifier where Self:ExpressibleByStringLiteral 
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension StringBackedIdentifier where Self:CustomStringConvertible
{
    @inlinable public 
    var description:String 
    {
        self.rawValue 
    }
}
