import MongoDB
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct PackageAlignOperation:Sendable
    {
        let package:Unidoc.Package
        let realm:String?
        let force:Bool

        init(package:Unidoc.Package,
            realm:String?,
            force:Bool)
        {
            self.package = package
            self.realm = realm.map { $0.isEmpty ? nil : $0 } ?? nil
            self.force = force
        }
    }
}
extension Unidoc.PackageAlignOperation:Unidoc.NonblockingOperation
{
    func enqueue(on server:Unidoc.Server,
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
        let package:Unidoc.PackageMetadata = try await server.db.packages.find(id: self.package,
            with: session)
        else
        {
            return .noSuchPackage
        }

        return .align(package, to: realm)
    }

    func perform(on server:Unidoc.Server, session:Mongo.Session, status:Status) async
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
