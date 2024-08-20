import GitHubAPI
import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocUI

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
        from packages:Unidoc.DB.Packages) async throws -> Symbol.Package?
    {
        let metadata:Unidoc.PackageMetadata?

        switch field
        {
        case .platformPreference(let triple):
            metadata = try await packages.reset(platformPreference: triple, of: self.package)

        case .media(let media):
            metadata = try await packages.reset(media: media, of: self.package)
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
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        if  let rejection:HTTP.ServerResponse = try await db.authorize(
                loading: self.package,
                account: self.account,
                rights: self.rights)
        {
            return rejection
        }

        let updated:Symbol.Package?
        let rebuildPackageList:Bool
        switch self.update
        {
        case .hidden(let hidden):
            let package:Unidoc.PackageMetadata? = try await db.packages.update(
                package: self.package,
                hidden: hidden)
            updated = package?.symbol
            rebuildPackageList = updated != nil

        case .expires(let when):
            if  case _? = try await db.crawlingTickets.move(
                ticket: self.package,
                time: when)
            {
                updated = nil
            }
            else if
                let package:Unidoc.PackageMetadata = try await db.packages.detachWebhook(
                    package: self.package),
                case .github(let origin)? = package.repo?.origin,
                let node:GitHub.Node = origin.node
            {
                let ticket:Unidoc.CrawlingTicket<Unidoc.Package> = .init(id: self.package,
                    node: node,
                    time: when)
                _ = try await db.crawlingTickets.create(tickets: [ticket])

                updated = package.symbol
            }
            else
            {
                return .notFound("Package does not exist, or is missing GitHub node metadata\n")
            }

            rebuildPackageList = false

        case .symbol(let symbol):
            let changed:Bool? = try await db.packages.update(
                package: self.package,
                symbol: symbol)

            updated = changed != nil ? symbol : nil
            rebuildPackageList = changed ?? false

        case .reset(let field):
            updated = try await self.reset(field: field, from: db.packages)
            rebuildPackageList = false
        }

        if  rebuildPackageList
        {
            try await db.rebuildPackageList()
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
