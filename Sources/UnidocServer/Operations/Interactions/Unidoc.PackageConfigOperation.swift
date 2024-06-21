import HTTP
import MongoDB
import UnidocUI
import Symbols
import UnidocDB

extension Unidoc
{
    struct PackageConfigOperation:Sendable
    {
        let account:Unidoc.Account?
        let package:Unidoc.Package
        let update:Update
        let from:String?

        private
        var rights:Unidoc.UserRights

        init(account:Unidoc.Account?, package:Unidoc.Package, update:Update, from:String? = nil)
        {
            self.account = account
            self.package = package
            self.update = update
            self.from = from

            self.rights = .init()
        }
    }
}
extension Unidoc.PackageConfigOperation
{
    private
    func reset(field:Update.Field,
        from packages:borrowing Unidoc.DB.Packages,
        with session:Mongo.Session) async throws -> Symbol.Package?
    {
        let metadata:Unidoc.PackageMetadata?

        switch field
        {
        case .platformPreference(let triple):
            metadata = try await packages.reset(
                platformPreference: triple,
                of: self.package,
                with: session)

        case .media(let media):
            metadata = try await packages.reset(
                media: media,
                of: self.package,
                with: session)
        }

        return metadata?.symbol
    }
}
extension Unidoc.PackageConfigOperation:Unidoc.RestrictedOperation
{
    /// Everyone can use this endpoint, as long as they are authenticated. The user’s
    /// relationship to the package will be checked later.
    mutating
    func admit(user:Unidoc.UserRights) -> Bool
    {
        self.rights = user
        return true
    }

    func load(from server:Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        if  let rejection:HTTP.ServerResponse = try await server.authorize(
                loading: self.package,
                account: self.account,
                rights: self.rights,
                with: session)
        {
            return rejection
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
            rebuildPackageList = updated != nil

        case .expires(let when):
            let package:Unidoc.PackageMetadata? = try await server.db.packages.update(
                package: self.package,
                expires: when,
                with: session)
            updated = package?.symbol
            rebuildPackageList = false

        case .symbol(let symbol):
            let changed:Bool? = try await server.db.packages.update(
                package: self.package,
                symbol: symbol,
                with: session)

            updated = changed != nil ? symbol : nil
            rebuildPackageList = changed ?? false

        case .reset(let field):
            updated = try await self.reset(field: field,
                from: server.db.packages,
                with: session)
            rebuildPackageList = false
        }

        if  rebuildPackageList
        {
            try await server.db.unidoc.rebuildPackageList(with: session)
        }

        if  let updated:Symbol.Package
        {
            return .redirect(.seeOther("\(Unidoc.RefsEndpoint[updated])"))
        }
        else if
            let back:String = self.from
        {
            return .redirect(.seeOther(back))
        }
        else
        {
            //  Not completely unreachable, due to race conditions.
            return .notFound("No such package")
        }
    }
}
