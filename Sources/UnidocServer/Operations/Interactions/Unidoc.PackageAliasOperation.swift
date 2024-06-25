import HTTP
import MongoDB
import UnidocDB
import UnidocUI
import Symbols

extension Unidoc
{
    struct PackageAliasOperation:Sendable
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
extension Unidoc.PackageAliasOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await server.db.packageAliases.upsert(alias: self.alias,
            of: self.package,
            with: session)

        return .redirect(.seeOther("\(Unidoc.RefsEndpoint[self.alias])"))
    }
}
