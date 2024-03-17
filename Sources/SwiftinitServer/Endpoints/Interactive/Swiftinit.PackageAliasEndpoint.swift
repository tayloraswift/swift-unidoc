import HTTP
import MongoDB
import UnidocDB
import Symbols

extension Swiftinit
{
    struct PackageAliasEndpoint:Sendable
    {
        let package:Unidoc.Package
        let alias:Symbol.Package

        init(package:Unidoc.Package, alias:Symbol.Package)
        {
            self.package = package
            self.alias = alias
        }
    }
}
extension Swiftinit.PackageAliasEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        try await server.db.packageAliases.upsert(alias: self.alias,
            of: self.package,
            with: session)

        return .redirect(.see(other: "\(Swiftinit.Tags[self.alias])"))
    }
}
