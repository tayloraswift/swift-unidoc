import HTTP
import MongoDB
import Symbols
import UnidocDB

extension Swiftinit
{
    struct PackageConfigEndpoint:Sendable
    {
        let account:Unidoc.Account
        let package:Unidoc.Package
        let update:Update

        private
        var rightsRequired:Unidoc.PackageRights

        init(account:Unidoc.Account, package:Unidoc.Package, update:Update)
        {
            self.account = account
            self.package = package
            self.update = update

            self.rightsRequired = .editor
        }
    }
}
extension Swiftinit.PackageConfigEndpoint:Swiftinit.RestrictedEndpoint
{
    /// Everyone can use this endpoint, as long as they are authenticated. The user’s
    /// relationship to the package will be checked later.
    mutating
    func admit(level:Unidoc.User.Level) -> Bool
    {
        if  case .administratrix = level
        {
            self.rightsRequired = .reader
        }

        return true
    }

    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        guard
        let rights:Unidoc.PackageRights = try await server.db.unidoc.rights(
            account: self.account,
            package: self.package,
            with: session)
        else
        {
            return .notFound("No such package")
        }

        if  rights < self.rightsRequired
        {
            return .forbidden("You are not authorized to edit this package!")
        }

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
            //  Not completely unreachable, due to race conditions.
            return .notFound("No such package")
        }

        if  rebuildPackageList
        {
            try await server.db.unidoc.rebuildPackageList(with: session)
        }

        return .redirect(.seeOther("\(Swiftinit.Tags[updated])"))
    }
}
