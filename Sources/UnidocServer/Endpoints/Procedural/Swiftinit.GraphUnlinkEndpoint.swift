import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct GraphUnlinkEndpoint:Sendable
    {
        let volume:VolumeIdentifier

        init(volume:VolumeIdentifier)
        {
            self.volume = volume
        }
    }
}
extension Swiftinit.GraphUnlinkEndpoint:BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload _:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        switch try await server.db.unidoc.unlink(volume: self.volume, with: session)
        {
        case  _?:   return .ok("")
        case nil:   return .error("No such volume.")
        }
    }
}