import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import UnidocRecords

extension Snapshot
{
    /// An identity for a symbol graph suitable for dependency resolution.
    ///
    /// This identity normalizes some variations in git refnames. For example, all of the
    /// following tags are normalized to `1.0.0`:
    ///
    /// -   `1.0.0`
    /// -   `1.0`
    /// -   `1`
    /// -   `v1.0.0`
    /// -   `v1.0`
    /// -   `v1`
    ///
    /// This implies that identity collisions are possible if package authors use multiple
    /// version formats to tag the same release.
    ///
    /// If a symbol graph lacks a git refname, and is not a standard library symbol graph,
    /// its effective version name is `0.0.0`.
    ///
    /// Refnames that are not semantic versions normalized to their lowercase form. As git
    /// refnames are case-sensitive, this can also produce collisions.
    @frozen public
    struct ID:Equatable, Hashable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let version:AnyVersion
        public
        let triple:Triple

        @inlinable public
        init(package:PackageIdentifier, version:AnyVersion, triple:Triple)
        {
            self.package = package
            self.version = version
            self.triple = triple
        }
    }
}
extension Snapshot.ID
{
    @inlinable public
    init(package:PackageIdentifier, refname:String? = nil, triple:Triple)
    {
        self.init(package: package,
            version: refname.map(AnyVersion.init(_:)) ?? .stable(.release(.v(0, 0, 0))),
            triple: triple)
    }
}
extension Snapshot.ID
{
    @inlinable public
    var volume:VolumeIdentifier
    {
        .init(
            package: self.package,
            version: self.version.stable?.patch.description ?? "\(self.version)")
    }
}
extension Snapshot.ID:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.package) \(self.version) \(self.triple)"
    }
}
extension Snapshot.ID:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        if  let i:String.Index = description.firstIndex(of: " "),
            let j:String.Index = description.lastIndex(of: " "),
            let triple:Triple = .init(description[description.index(after: j)...])
        {
            self.init(
                package: .init(description[..<i]),
                version: .init(description[description.index(after: i) ..< j]),
                triple: triple)
        }
        else
        {
            return nil
        }
    }
}
extension Snapshot.ID:BSONStringEncodable, BSONStringDecodable
{
}
