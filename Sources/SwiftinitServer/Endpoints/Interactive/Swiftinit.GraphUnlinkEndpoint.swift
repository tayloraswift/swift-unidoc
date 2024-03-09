import HTTP
import MongoDB
import Symbols
import UnidocDB

extension Swiftinit
{
    struct GraphUnlinkEndpoint:Sendable
    {
        let volume:Unidoc.Edition
        let uri:String?

        init(volume:Unidoc.Edition, uri:String?)
        {
            self.volume = volume
            self.uri = uri
        }
    }
}
extension Swiftinit.GraphUnlinkEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        guard
        let volume:Unidoc.VolumeMetadata = try await server.db.volumes.find(id: self.volume,
            with: session)
        else
        {
            return .notFound("No such volume!")
        }

        try await server.db.unidoc.unlink(volume: volume, with : session)

        return .redirect(.see(other: self.uri ?? "/admin"))
    }
}
