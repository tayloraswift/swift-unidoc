import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct PackageEndpoint:Sendable
    {
        let operation:Operation
        let package:Symbol.Package

        init(operation:Operation, package:Symbol.Package)
        {
            self.operation = operation
            self.package = package
        }
    }
}
extension Swiftinit.PackageEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        switch self.operation
        {
        case .update(let update):
            guard
            let package:Unidex.Package = try await server.db.unidoc.execute(
                query: Unidex.PackageQuery.init(symbol: self.package),
                with: session)
            else
            {
                return .ok("Package not found")
            }

            switch update
            {
            case .realm(let realm?):
                guard
                let realm:Unidex.Realm = try await server.db.unidoc.execute(
                    query: Unidex.RealmQuery.init(symbol: realm),
                    with: session)
                else
                {
                    return .ok("Realm not found")
                }

                try await server.db.unidoc.align(package: package.id,
                    realm: realm.id,
                    with: session)

            case .realm(nil):
                try await server.db.unidoc.align(package: package.id,
                    realm: nil,
                    with: session)
            }
        }

        return .ok("Success")
    }
}
