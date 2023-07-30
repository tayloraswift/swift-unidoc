import FNV1
import ModuleGraphs
import UnidocRecords

/// A deep query is a query for a single code-level entity,
/// such as a declaration or a module.
@frozen public
struct DeepQuery:Equatable, Sendable
{
    /// The set of unidoc planes to filter by.
    public
    var planes:Planes
    public
    var package:PackageIdentifier
    public
    var version:Substring?
    public
    var stem:Record.Stem
    public
    var hash:FNV24?

    @inlinable public
    init(_ planes:Planes,
        package:PackageIdentifier,
        version:Substring?,
        stem:Record.Stem,
        hash:FNV24? = nil)
    {
        self.planes = planes

        self.package = package
        self.version = version
        self.stem = stem
        self.hash = hash
    }
}
extension DeepQuery
{
    public
    init(_ planes:Planes, _ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        if  let colon:String.Index = trunk.firstIndex(of: ":")
        {
            self.init(planes,
                package: .init(trunk[..<colon]),
                version: trunk[trunk.index(after: colon)...],
                stem: .init(path: stem),
                hash: hash)
        }
        else
        {
            self.init(planes,
                package: .init(trunk),
                version: nil,
                stem: .init(path: stem),
                hash: hash)
        }
    }
}
