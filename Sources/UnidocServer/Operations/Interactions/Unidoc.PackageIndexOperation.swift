import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import SwiftinitPages
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct PackageIndexOperation:Sendable
    {
        let account:Unidoc.Account
        let owner:String
        let repo:String
        let from:String?

        private
        var privileges:Unidoc.User.Level

        init(account:Unidoc.Account, owner:String, repo:String, from:String? = nil)
        {
            self.account = account
            self.owner = owner
            self.repo = repo
            self.from = from

            self.privileges = .human
        }
    }
}
extension Unidoc.PackageIndexOperation:Unidoc.RestrictedOperation
{
    /// Everyone can use this endpoint, as long as they are authenticated.
    mutating
    func admit(level:Unidoc.User.Level) -> Bool
    {
        self.privileges = level
        return true
    }

    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let github:GitHub.Client<GitHub.API<String>>
        if  let api:GitHub.API<String> = server.github?.api
        {
            github = .graphql(api: api,
                threads: server.context.threads,
                niossl: server.context.niossl)
        }
        else
        {
            return nil
        }

        //  The cost for administratrices is not *zero*, mainly so that it’s easier for us to
        //  tell if the rate limiting system is working.
        guard
        let _:Int = try await server.db.users.charge(apiKey: nil,
            user: self.account,
            cost: self.privileges == .administratrix ? 1 : 8,
            with: session)
        else
        {
            let display:Unidoc.PolicyErrorPage = .init(illustration: .error4xx_jpg,
                message: "Inactive or nonexistent API key")
            return .resource(display.resource(format: server.format), status: 429)
        }

        let response:GitHub.RepoMonitorResponse = try await github.connect
        {
            try await $0.crawl(owner: self.owner, repo: self.repo, tags: 0)
        }

        guard
        let repo:GitHub.Repo = response.repo
        else
        {
            let display:Unidoc.PolicyErrorPage = .init(illustration: .error404_jpg,
                message: "No such GitHub repository!")
            return .notFound(display.resource(format: server.format))
        }

        if  case .human = self.privileges,
            self.account != .init(type: .github, user: repo.owner.id)
        {
            let display:Unidoc.PolicyErrorPage = .init(illustration: .error4xx_jpg,
                message: "You are not the owner of this repository!")
            return .forbidden(display.resource(format: server.format))
        }

        guard repo.owner.login.allSatisfy({ $0 != "." })
        else
        {
            let display:Unidoc.PolicyErrorPage = .init(illustration: .error4xx_jpg,
                message: "Cannot index a repository with a dot in the owner’s name!")
            return .resource(display.resource(format: server.format), status: 400)
        }

        let symbol:Symbol.Package = .init("\(repo.owner.login).\(repo.name)")

        let (package, _):(Unidoc.PackageMetadata, new:Bool) = try await server.db.unidoc.index(
            package: symbol,
            repo: .github(repo, crawled: .now()),
            mode: .automatic,
            with: session)

        return .redirect(.seeOther("\(Swiftinit.Tags[package.symbol])"))
    }
}
