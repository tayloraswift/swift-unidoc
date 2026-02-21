import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords
import UnidocUI

extension Unidoc {
    struct PackageIndexOperation: Sendable {
        let account: Account
        let subject: Subject

        var rights: UserRights

        init(account: Account, subject: Subject) {
            self.account = account
            self.subject = subject

            self.rights = .init()
        }
    }
}
extension Unidoc.PackageIndexOperation: Unidoc.MeteredOperation {
    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as format: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        guard
        let github: any Unidoc.Registrar = server.github else {
            return nil
        }

        let package: Unidoc.PackageMetadata

        switch self.subject {
        case .repo(owner: let owner, name: let name, githubInstallation: let appInstallation):
            if  let error: Unidoc.PolicyErrorPage = try await self.charge(cost: 8, in: db) {
                return error.response(format: format)
            }

            let repo: GitHub.Repo? = try await github.connect(
                with: .init(githubInstallation: appInstallation)
            ) {
                try await $0.lookup(owner: owner, repo: name)
            }

            guard
            let repo: GitHub.Repo else {
                let display: Unidoc.PolicyErrorPage = .init(
                    illustration: .github_jpg,
                    heading: "No such GitHub repository!",
                    message: """
                    The role you selected does not have access to a GitHub repository with the \
                    name '\(owner)/\(name)'.
                    """,
                    status: 404
                )
                return display.response(format: format)
            }

            if  let failure: Unidoc.PolicyErrorPage = try await self.validate(repo: repo) {
                return failure.response(format: format)
            }

            (package, _) = try await db.index(
                package: "\(repo.owner.login).\(repo.name)",
                repo: .github(repo, crawled: .now()),
                mode: .automatic
            )

            //  If we are (re)indexing a package this way, we should create a crawling ticket
            //  for the repo, for lack of a proper interface for requesting this.
            if  case .public = repo.visibility {
                _ = try await db.crawlingTickets.create(
                    tickets: [.init(id: package.id, node: repo.node, time: .zero)]
                )
            }

        case .ref(let id, ref: let name):
            if  let metadata: Unidoc.PackageMetadata = try await db.packages.find(id: id) {
                package = metadata
            } else {
                return .notFound("No such package")
            }

            guard
            case .github(let origin) = package.repo?.origin else {
                return .notFound("Not a GitHub repository")
            }

            if  let error: Unidoc.PolicyErrorPage = try await self.charge(cost: 8, in: db) {
                return error.response(format: format)
            }

            let ref: GitHub.Ref? = try await github.connect(with: .init()) {
                try await $0.lookup(owner: origin.owner, repo: origin.name, ref: name)
            }

            guard
            let ref: GitHub.Ref else {
                let display: Unidoc.PolicyErrorPage = .init(
                    illustration: .github_jpg,
                    heading: "No such ref!",
                    message: """
                    Could not find the ref '\(name)' in the GitHub repository \
                    '\(origin.owner)/\(origin.name)'.
                    """,
                    status: 404
                )
                return display.response(format: format)
            }

            let version: SemanticVersion? = package.symbol.version(tag: ref.name)
            let sha1: SHA1?

            switch ref.prefix {

            case nil, .remotes?:
                return .ok("Ignored remote '\(ref.name)': not a tag or branch")

            case .tags?:
                guard case _? = version else {
                    return .ok("Ignored tag '\(ref.name)': not a semantic or swift version")
                }

                sha1 = ref.hash

            case .heads?:
                sha1 = nil
            }

            let (_, _): (Unidoc.EditionMetadata, Bool) = try await db.index(
                package: package.id,
                version: version,
                name: ref.name,
                sha1: sha1
            )
        }

        return .redirect(.seeOther("\(Unidoc.RefsEndpoint[package.symbol])"))
    }
}
extension Unidoc.PackageIndexOperation {
    private func validate(repo: GitHub.Repo) async throws -> Unidoc.PolicyErrorPage? {
        if  case .human = self.rights.level {
            let rights: Unidoc.PackageRights = .of(
                account: self.account,
                access: self.rights.access,
                rulers: .init(
                    editors: [],
                    owner: .init(type: .github, user: repo.owner.id)
                )
            )

            if  rights < .editor {
                return .init(
                    illustration: .error4xx_jpg,
                    heading: "Insufficient permissions",
                    message: "You are not authorized to index this repository!",
                    status: 403
                )
            }
        }

        if  repo.owner.login.allSatisfy({ $0 != "." }) {
            return nil
        } else {
            return .init(
                illustration: .error4xx_jpg,
                heading: "Server policy error",
                message: "Cannot index a repository with a dot in the owner’s name!",
                status: 400
            )
        }
    }
}
