import Unidoc
import UnidocLinker

@frozen public
struct SnapshotReceipt:Equatable, Sendable
{
    public
    let id:Snapshot.ID
    public
    let edition:Unidoc.Zone
    public
    var type:Upsert
    public
    var repo:PackageRepo?

    @inlinable public
    init(id:Snapshot.ID, edition:Unidoc.Zone, type:Upsert, repo:PackageRepo? = nil)
    {
        self.id = id
        self.edition = edition
        self.type = type
        self.repo = repo
    }
}
extension SnapshotReceipt
{
    @inlinable public
    var package:Int32 { self.edition.package }

    @inlinable public
    var version:Int32 { self.edition.version }
}
