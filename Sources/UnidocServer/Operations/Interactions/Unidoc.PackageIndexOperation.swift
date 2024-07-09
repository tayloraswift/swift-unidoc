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

        var rights:UserRights

        init(account:Account, subject:Subject)
        {
            self.account = account
            self.subject = subject

            self.rights = .init()
        }
    }
}
extension Unidoc.PackageIndexOperation:Unidoc.MeteredOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        guard
        let github:any Unidoc.Registrar = server.github
        else
        {
            return nil
        }

        let package:Unidoc.PackageMetadata

        switch self.subject
        {
        case .repo(owner: let owner, name: let repo):
            if  let error:Unidoc.PolicyErrorPage = try await self.charge(cost: 8,
                    from: server,
                    with: session)
            {
                return error.response(format: format)
            }

            let repo:GitHub.Repo? = try await github.connect(with: server.context)
            {
                try await $0.lookup(owner: owner, repo: repo)
            }

            guard
            let repo:GitHub.Repo
            else
            {
                let display:Unidoc.PolicyErrorPage = .init(illustration: .error404_jpg,
                    message: "No such GitHub repository!",
                    status: 404)
                return display.response(format: format)
            }

            if  let failure:Unidoc.PolicyErrorPage = try await self.validate(repo: repo)
            {
                return failure.response(format: format)
            }

            (package, _) = try await server.db.unidoc.index(
                package: "\(repo.owner.login).\(repo.name)",
                repo: .github(repo, crawled: .now()),
                mode: .automatic,
                with: session)

            //  If we are (re)indexing a package this way, we should create a crawling ticket
            //  for the repo, for lack of a proper interface for requesting this.
            _ = try await server.db.crawlingTickets.create(
                tickets: [.init(id: package.id, node: repo.node, time: .zero)],
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

            if  let error:Unidoc.PolicyErrorPage = try await self.charge(cost: 8,
                    from: server,
                    with: session)
            {
                return error.response(format: format)
            }

            let ref:GitHub.Ref? = try await github.connect(with: server.context)
            {
                try await $0.lookup(owner: origin.owner, repo: origin.name, ref: ref)
            }

            guard
            let ref:GitHub.Ref
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

        return .redirect(.seeOther("\(Unidoc.RefsEndpoint[package.symbol])"))
    }
}
extension Unidoc.PackageIndexOperation
{
    private
    func validate(repo:GitHub.Repo) async throws -> Unidoc.PolicyErrorPage?
    {
        if  case .human = self.rights.level
        {
            let rights:Unidoc.PackageRights = .of(account: self.account,
                access: self.rights.access,
                rulers: .init(editors: [],
                    owner: .init(type: .github, user: repo.owner.id)))

            if  rights < .editor
            {
                return .init(illustration: .error4xx_jpg,
                    message: "You are not authorized to index this repository!",
                    status: 403)
            }
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
