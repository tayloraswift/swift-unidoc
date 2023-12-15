import MongoDB
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct PackageAlignEndpoint:Sendable
    {
        let package:Symbol.Package
        let realm:String?
        let force:Bool
    }
}
extension Swiftinit.PackageAlignEndpoint:NonblockingEndpoint
{
    func enqueue(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> Status
    {
        let realm:Unidoc.Realm?

        if  let symbol:String = self.realm
        {
            let target:Unidoc.RealmMetadata?
            if  self.force
            {
                (target, _) = try await server.db.unidoc.index(realm: symbol, with: session)
            }
            else
            {
                target = try await server.db.unidoc.realm(named: symbol, with: session)
            }

            guard
            let target:Unidoc.RealmMetadata
            else
            {
                return .noSuchRealm
            }

            realm = target.id
        }
        else
        {
            realm = nil
        }

        guard
        let package:Unidoc.PackageMetadata = try await server.db.unidoc.package(
            named: self.package,
            with: session)
        else
        {
            return .noSuchPackage
        }

        return .align(package, to: realm)
    }

    func perform(on server:borrowing Swiftinit.Server,
        session:Mongo.Session,
        status:Status) async
    {
        switch status
        {
        case .align(let package, let realm):
            try? await server.db.unidoc.align(package: package.id, realm: realm, with: session)

        default:
            break
        }
    }
}
