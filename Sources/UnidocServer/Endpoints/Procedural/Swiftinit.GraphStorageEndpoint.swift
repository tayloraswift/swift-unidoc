import BSON
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    enum GraphStorageEndpoint:Sendable
    {
        case put
    }
}
extension Swiftinit.GraphStorageEndpoint:BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .put:
            let snapshot:Unidex.Snapshot = try .init(
                bson: BSON.DocumentView<[UInt8]>.init(slice: payload))

            let uploaded:UnidocDatabase.Uploaded = try await server.db.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            return .ok(uploaded.updated ? "Updated" : "Inserted")
        }
    }
}
