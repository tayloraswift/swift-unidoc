import MongoDB
import MongoTesting
import SymbolGraphs
import UnidocDB

extension Unidoc.DB
{
    /// Indexes and stores a symbol graph in the database, queueing it for an **asynchronous**
    /// uplink.
    func store(docs documentation:consuming SymbolGraphObject<Void>,
        with session:Mongo.Session) async throws -> Unidoc.UploadStatus
    {
        let (snapshot, _):(Unidoc.Snapshot, Unidoc.Realm?) = try await self.label(
            documentation: documentation,
            action: .uplinkInitial,
            with: session)

        return try await self.snapshots.upsert(snapshot: snapshot, with: session)
    }
}
