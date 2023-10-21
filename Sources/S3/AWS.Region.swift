extension AWS
{
    /// TODO: Add all regions.
    @frozen public
    enum Region:String, Hashable, Sendable
    {
        case us_east_1 = "us-east-1"
    }
}
extension AWS.Region
{
    @inlinable public
    var utf8:String.UTF8View { self.rawValue.utf8 }
}
extension AWS.Region:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
