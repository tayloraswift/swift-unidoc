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
extension Swiftinit.GraphStorageEndpoint:ProceduralEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        with payload:[UInt8]) async throws -> HTTP.ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        switch self
        {
        case .put:
            let snapshot:Unidex.Snapshot = try .init(
                bson: BSON.DocumentView<[UInt8]>.init(slice: payload))

            let uploaded:UnidocDatabase.Uploaded = try await server.db.unidoc.snapshots.upsert(
                snapshot: snapshot,
                with: session)

            return .ok(uploaded.updated ? "Updated" : "Inserted")
        }
    }
}
