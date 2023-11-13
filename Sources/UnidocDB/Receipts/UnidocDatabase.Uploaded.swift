import Unidoc
import UnidocLinker
import UnidocRecords

@available(*, deprecated, renamed: "UnidocDatabase.Uploaded")
public
typealias SnapshotReceipt = UnidocDatabase.Uploaded

extension UnidocDatabase
{
    @frozen public
    struct Uploaded:Equatable, Sendable
    {
        public
        let id:Snapshot.ID
        public
        let edition:Unidoc.Edition
        public
        let realm:Realm
        public
        var graph:UnidocDatabase.Graphs.Upsert

        @inlinable public
        init(id:Snapshot.ID,
            edition:Unidoc.Edition,
            realm:Realm,
            graph:UnidocDatabase.Graphs.Upsert)
        {
            self.id = id
            self.edition = edition
            self.realm = realm
            self.graph = graph
        }
    }
}
extension UnidocDatabase.Uploaded
{
    @inlinable public
    var package:Int32 { self.edition.package }

    @inlinable public
    var version:Int32 { self.edition.version }
}
