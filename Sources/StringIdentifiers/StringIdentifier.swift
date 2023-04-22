public
protocol StringIdentifier:LosslessStringConvertible, CustomStringConvertible
{
    init(_ description:String)
}
extension StringIdentifier where Self:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool 
    {
        lhs.description < rhs.description
    }
}
extension StringIdentifier where Self:ExpressibleByStringLiteral 
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
