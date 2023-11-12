import Unidoc
import UnidocLinker
import UnidocRecords

@frozen public
struct SnapshotReceipt:Equatable, Sendable
{
    public
    let id:Snapshot.ID
    public
    let edition:Unidoc.Edition
    public
    let realm:Realm
    public
    var type:Upsert

    @inlinable public
    init(id:Snapshot.ID,
        edition:Unidoc.Edition,
        realm:Realm,
        type:Upsert)
    {
        self.id = id
        self.edition = edition
        self.realm = realm
        self.type = type
    }
}
extension SnapshotReceipt
{
    @inlinable public
    var package:Int32 { self.edition.package }

    @inlinable public
    var version:Int32 { self.edition.version }
}
