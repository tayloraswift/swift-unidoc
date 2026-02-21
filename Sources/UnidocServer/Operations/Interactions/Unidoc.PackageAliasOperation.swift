import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocUI

extension Unidoc {
    struct PackageAliasOperation: Sendable {
        let package: Unidoc.Package
        let alias: Symbol.Package

        init(package: Unidoc.Package, alias: Symbol.Package) {
            self.package = package
            self.alias = alias
        }
    }
}
extension Unidoc.PackageAliasOperation: Unidoc.AdministrativeOperation {
    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as _: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        try await db.packageAliases.upsert(alias: self.alias, of: self.package)
        return .redirect(.seeOther("\(Unidoc.RefsEndpoint[self.alias])"))
    }
}
