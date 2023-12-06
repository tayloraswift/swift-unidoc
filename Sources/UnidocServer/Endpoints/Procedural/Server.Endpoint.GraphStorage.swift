import BSON
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    enum GraphStorage:Sendable
    {
        case put
    }
}
extension Server.Endpoint.GraphStorage:ProceduralEndpoint
{
    func perform(on server:Server, with payload:[UInt8]) async throws -> HTTP.ServerResponse
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
