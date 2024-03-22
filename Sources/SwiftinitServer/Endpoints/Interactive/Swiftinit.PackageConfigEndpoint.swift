import HTTP
import MongoDB
import Symbols
import UnidocDB

extension Swiftinit
{
    struct PackageConfigEndpoint:Sendable
    {
        let package:Unidoc.Package
        let update:Update

        init(package:Unidoc.Package, update:Update)
        {
            self.package = package
            self.update = update
        }
    }
}
extension Swiftinit.PackageConfigEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let updated:Symbol.Package?
        let rebuildPackageList:Bool
        switch self.update
        {
        case .hidden(let hidden):
            let package:Unidoc.PackageMetadata? = try await server.db.packages.update(
                package: self.package,
                hidden: hidden,
                with: session)
            updated = package?.symbol
            rebuildPackageList = true

        case .expires(let when):
            let package:Unidoc.PackageMetadata? = try await server.db.packages.update(
                package: self.package,
                expires: when,
                with: session)
            updated = package?.symbol
            rebuildPackageList = false

        case .symbol(let symbol):
            let package:Bool? = try await server.db.packages.update(
                package: self.package,
                symbol: symbol,
                with: session)

            updated = package != nil ? symbol : nil
            rebuildPackageList = true
        }

        guard
        let updated:Symbol.Package
        else
        {
            return .notFound("No such package")
        }

        if  rebuildPackageList
        {
            try await server.db.unidoc.rebuildPackageList(with: session)
        }

        return .redirect(.seeOther("\(Swiftinit.Tags[updated])"))
    }
}
