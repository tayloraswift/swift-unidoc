extension Symbol
{
    @frozen public
    struct PackageScope:Equatable, Hashable, Sendable
    {
        /// The string identifier wrapped by this symbol. It may never contain dots and is
        /// always lowercased.
        public
        let identifier:String

        @inlinable
        init(identifier:String)
        {
            self.identifier = identifier
        }
    }
}
extension Symbol.PackageScope:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.identifier < b.identifier }
}
extension Symbol.PackageScope:CustomStringConvertible
{
    @inlinable public
    var description:String { self.identifier }
}
extension Symbol.PackageScope:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        if  string.contains(".")
        {
            return nil
        }
        else
        {
            self.init(identifier: string.lowercased())
        }
    }
}
