import HTTP
import MongoDB
import UnidocDB

extension Server.Endpoint
{
    struct GraphUplink:Sendable
    {
        let package:Int32
        let version:Int32

        init(package:Int32, version:Int32)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Server.Endpoint.GraphUplink:ProceduralEndpoint
{
    func perform(on server:Server.ProceduralState) async throws -> ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        let uplinked:Int = try await server.db.unidoc.uplink(
            package: self.package,
            version: self.version,
            with: session)

        if  uplinked == 1
        {
            return .ok("")
        }
        else
        {
            return .error("No such symbol graph.")
        }
    }
}
