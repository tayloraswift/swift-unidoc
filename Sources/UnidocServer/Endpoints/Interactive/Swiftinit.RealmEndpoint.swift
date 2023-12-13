import HTTP
import MongoDB
import UnidocDB

extension Swiftinit
{
    struct RealmEndpoint:Sendable
    {
        let operation:Operation
        let realm:String

        init(operation:Operation, realm:String)
        {
            self.operation = operation
            self.realm = realm
        }
    }
}
extension Swiftinit.RealmEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        switch self.operation
        {
        case .create:
            switch try await server.db.unidoc.index(realm: self.realm, with: session)
            {
            case (let realm, new: false):
                return .ok("Realm already exists (\(realm.id))")

            case (let realm, new: true):
                return .ok("Realm created (\(realm.id))")
            }
        }
    }
}
