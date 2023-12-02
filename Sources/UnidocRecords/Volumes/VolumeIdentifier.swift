import BSON
import Symbols

@frozen public
struct VolumeIdentifier:Equatable, Hashable, Sendable
{
    public
    var package:Symbol.Package
    /// A string identifying the package version within the database.
    /// If the ``refname`` is a `v`-prefixed semantic version, this
    /// string encodes the version without the `v` prefix.
    public
    var version:String

    @inlinable public
    init(package:Symbol.Package, version:String)
    {
        self.package = package
        self.version = version
    }
}
extension VolumeIdentifier:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.package):\(self.version)" }
}
extension VolumeIdentifier:LosslessStringConvertible
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
extension VolumeIdentifier:BSONStringEncodable, BSONStringDecodable
{
}
