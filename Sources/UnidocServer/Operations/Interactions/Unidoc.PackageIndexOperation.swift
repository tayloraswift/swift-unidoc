import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import UnidocUI
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct PackageIndexOperation:Sendable
    {
        let account:Account
        let subject:Subject

        var privileges:User.Level

        init(account:Account, subject:Subject)
        {
            self.account = account
            self.subject = subject

            self.privileges = .human
        }
    }
}
extension Unidoc.PackageIndexOperation:Unidoc.MeteredOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let github:GitHub.Client<GitHub.PersonalAccessToken>
        if  let integration:GitHub.Integration = server.github
        {
            github = .graphql(pat: integration.pat,
                threads: server.context.threads,
                niossl: server.context.niossl,
                as: integration.agent)
        }
        else
        {
            return nil
        }

        let package:Unidoc.PackageMetadata

        switch self.subject
        {
        case .repo(owner: let owner, name: let repo):
            if  let error:HTTP.ServerResponse = try await self.charge(cost: 8,
                    from: server,
                    with: session)
            {
                return error
            }

            let response:GitHub.RepoMonitorResponse = try await github.connect
            {
                try await $0.crawl(owner: owner, repo: repo, tags: 0)
            }

            guard
            let repo:GitHub.Repo = response.repo
            else
            {
                let display:Unidoc.PolicyErrorPage = .init(illustration: .error404_jpg,
                    message: "No such GitHub repository!",
                    status: 404)
                return display.response(format: server.format)
            }

            if  let failure:Unidoc.PolicyErrorPage = try await self.validate(repo: repo)
            {
                return failure.response(format: server.format)
            }

            (package, _) = try await server.db.unidoc.index(
                package: .init("\(repo.owner.login).\(repo.name)"),
                repo: .github(repo, crawled: .now()),
                mode: .automatic,
                with: session)


        case .ref(let id, ref: let ref):
            if  let metadata:Unidoc.PackageMetadata = try await server.db.packages.find(id: id,
                    with: session)
            {
                package = metadata
            }
            else
            {
                return .notFound("No such package")
            }

            guard
            case .github(let origin) = package.repo?.origin
            else
            {
                return .notFound("Not a GitHub repository")
            }

            if  let error:HTTP.ServerResponse = try await self.charge(cost: 8,
                    from: server,
                    with: session)
            {
                return error
            }

            let response:GitHub.RefResponse = try await github.connect
            {
                try await $0.inspect(ref: ref, owner: origin.owner, repo: origin.name)
            }

            guard
            let ref:GitHub.Ref = response.ref
            else
            {
                return .notFound("No such ref")
            }

            let version:SemanticVersion? = package.symbol.version(tag: ref.name)
            let sha1:SHA1?

            switch ref.prefix
            {

            case nil, .remotes?:
                return .ok("Ignored remote '\(ref.name)': not a tag or branch")

            case .tags?:
                guard case _? = version
                else
                {
                    return .ok("Ignored tag '\(ref.name)': not a semantic or swift version")
                }

                sha1 = ref.hash

            case .heads?:
                sha1 = nil
            }

            let (_, _):(Unidoc.EditionMetadata, Bool) = try await server.db.unidoc.index(
                package: package.id,
                version: version,
                name: ref.name,
                sha1: sha1,
                with: session)
        }

        return .redirect(.seeOther("\(Unidoc.TagsEndpoint[package.symbol])"))
    }
}
extension Unidoc.PackageIndexOperation
{
    private
    func validate(repo:GitHub.Repo) async throws -> Unidoc.PolicyErrorPage?
    {
        if  case .human = self.privileges,
            self.account != .init(type: .github, user: repo.owner.id)
        {
            return .init(illustration: .error4xx_jpg,
                message: "You are not the owner of this repository!",
                status: 403)
        }

        if  repo.owner.login.allSatisfy({ $0 != "." })
        {
            return nil
        }
        else
        {
            return .init(illustration: .error4xx_jpg,
                message: "Cannot index a repository with a dot in the owner’s name!",
                status: 400)
        }
    }
}
