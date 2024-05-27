extension Symbol
{
    @frozen public
    struct Volume:Equatable, Hashable, Sendable
    {
        public
        var package:Package
        /// A string identifying the package version within the database.
        /// If the ``refname`` is a `v`-prefixed semantic version, this
        /// string encodes the version without the `v` prefix.
        public
        var version:String

        @inlinable public
        init(package:Package, version:String)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Symbol.Volume:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.package):\(self.version)" }
}
extension Symbol.Volume:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let colon:String.Index = description.firstIndex(of: ":")
        {
            self.init(
                package: .init(description[..<colon]),
                version: .init(description[description.index(after: colon)...]))
        }
        else
        {
            return nil
        }
    }
}
