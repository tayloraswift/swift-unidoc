extension Symbol
{
    @frozen public
    struct Product:Equatable, Hashable, Sendable
    {
        public
        let package:Package
        public
        let name:String

        @inlinable public
        init(name:String, package:Package)
        {
            self.package = package
            self.name = name
        }
    }
}
extension Symbol.Product:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.package, lhs.name) < (rhs.package, rhs.name)
    }
}
extension Symbol.Product:Identifiable
{
    /// Returns `self`.
    @inlinable public
    var id:Self { self }
}
extension Symbol.Product:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.package):\(self.name)"
    }
}
extension Symbol.Product:LosslessStringConvertible
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
