import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    enum GraphUplink:Sendable
    {
        case coordinate(Int32, Int32)
        case identifier(VolumeIdentifier)
    }
}
extension Server.Endpoint.GraphUplink:ProceduralEndpoint
{
    func perform(on server:Server.ProceduralState) async throws -> ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let linked:Int = switch self
        {
        case .coordinate(let package, let version):
            try await server.db.unidoc.uplink(
                package: package,
                version: version,
                with: session)

        case .identifier(let volume):
            try await server.db.unidoc.uplink(volume: volume, with: session)
        }

        if  linked == 1
        {
            return .ok("")
        }
        else
        {
            return .error("No such symbol graph.")
        }
    }
}
