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
extension ProductIdentifier:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.package):\(self.name)"
    }
}
