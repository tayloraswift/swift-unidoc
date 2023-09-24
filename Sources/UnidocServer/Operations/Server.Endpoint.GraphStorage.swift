import BSONDecoding
import HTTP
import MongoDB
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
    func perform(on server:Server.ProceduralState,
        with ticket:Int64) async throws -> ServerResponse
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
                return .ok(.init(
                    content: .string("Inserted"),
                    type: .text(.plain, charset: .utf8)))

            case .update:
                return .ok(.init(
                    content: .string("Updated"),
                    type: .text(.plain, charset: .utf8)))
            }
        }
    }
}
