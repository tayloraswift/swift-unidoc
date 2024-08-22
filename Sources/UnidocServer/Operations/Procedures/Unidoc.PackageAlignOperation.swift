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
    func enqueue(payload _:[UInt8],
        on server:Unidoc.Server,
        db:Unidoc.DB) async throws -> Status
    {
        let realm:Unidoc.Realm?

        if  let symbol:String = self.realm
        {
            let target:Unidoc.RealmMetadata?
            if  self.force
            {
                (target, _) = try await db.index(realm: symbol)
            }
            else
            {
                target = try await db.realm(named: symbol)
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
        let package:Unidoc.PackageMetadata = try await db.packages.find(id: self.package)
        else
        {
            return .noSuchPackage
        }

        return .align(package, to: realm)
    }

    func perform(status:Status, on _:Unidoc.Server, db:Unidoc.DB) async
    {
        switch status
        {
        case .align(let package, let realm):
            try? await db.align(package: package.id, realm: realm)

        default:
            break
        }
    }
}
