import BSONDecoding
import HTTP
import MongoDB
import UnidocDB
import UnidocLinker

extension Server.Endpoint
{
    enum GraphStorage:Sendable
    {
        case put
    }
}
extension Server.Endpoint.GraphStorage:ProceduralEndpoint
{
    func perform(on server:Server, with payload:[UInt8]) async throws -> ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        switch self
        {
        case .put:
            let snapshot:Snapshot = try .init(
                bson: BSON.DocumentView<[UInt8]>.init(slice: payload))

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
