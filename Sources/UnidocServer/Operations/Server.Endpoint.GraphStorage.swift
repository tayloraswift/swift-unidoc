import BSONDecoding
import HTTP
import MongoDB
import UnidocDB
import UnidocLinker

extension Server.Endpoint
{
    enum GraphStorage:Sendable
    {
        case put(bson:[UInt8])
    }
}
extension Server.Endpoint.GraphStorage:ProceduralEndpoint
{
    func perform(on server:Server.ProceduralState) async throws -> ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        switch self
        {
        case .put(let bson):
            let snapshot:Snapshot = try .init(
                bson: BSON.DocumentView<[UInt8]>.init(slice: bson))

            switch try await server.db.unidoc.graphs.upsert(snapshot, with: session)
            {
            case .insert:
                return .ok("Inserted")

            case .update:
                return .ok("Updated")
            }
        }
    }
}
