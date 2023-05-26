@frozen public
struct ProductIdentifier:Equatable, Hashable, Sendable
{
    public
    let package:PackageIdentifier
    public
    let name:String

    @inlinable public
    init(name:String, package:PackageIdentifier)
    {
        self.package = package
        self.name = name
    }
}
extension ProductIdentifier:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.package, lhs.name) < (rhs.package, rhs.name)
    }
}
extension ProductIdentifier:Identifiable
{
    /// Returns `self`.
    @inlinable public
    var id:Self { self }
}
extension ProductIdentifier:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.package):\(self.name)"
    }
}
extension ProductIdentifier:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        if  let colon:String.Index = description.firstIndex(of: ":")
        {
            self.init(name: .init(description[description.index(after: colon)...]),
                package: .init(description[..<colon]))
        }
        else
        {
            return nil
        }
    }
}
