import MongoQL
import UnidocRecords

extension Unidoc.SnapshotDelta:Mongo.MasterCodingDelta
{
    public
    typealias Model = Unidoc.Snapshot
}
