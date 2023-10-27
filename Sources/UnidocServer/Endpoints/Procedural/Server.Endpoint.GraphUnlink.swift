import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    struct GraphUnlink:Sendable
    {
        let volume:VolumeIdentifier

        init(volume:VolumeIdentifier)
        {
            self.volume = volume
        }
    }
}
extension Server.Endpoint.GraphUnlink:ProceduralEndpoint
{
    func perform(on server:Server, with _:[UInt8]) async throws -> ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        switch try await server.db.unidoc.unlink(volume: self.volume, with: session)
        {
        case  _?:   return .ok("")
        case nil:   return .error("No such volume.")
        }
    }
}
