import GitHubAPI
import HTTP
import MongoDB
import UnidocUI
import Symbols
import UnidocDB

extension Unidoc
{
    struct UpdatePackageRuleOperation:Sendable
    {
        let account:Unidoc.Account
        let package:Unidoc.Package
        let rule:UpdatePackageRule

        private
        var rights:Unidoc.UserRights

        init(account:Unidoc.Account, package:Unidoc.Package, rule:UpdatePackageRule)
        {
            self.account = account
            self.package = package
            self.rule = rule

            self.rights = .init()
        }
    }
}
extension Unidoc.UpdatePackageRuleOperation:Unidoc.RestrictedOperation
{
    mutating
    func admit(user:Unidoc.UserRights) -> Bool
    {
        self.rights = user
        return true
    }

    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        if  let rejection:HTTP.ServerResponse = try await server.authorize(
                loading: self.package,
                account: self.account,
                rights: self.rights,
                require: .owner,
                with: session)
        {
            return rejection
        }

        let package:Unidoc.PackageMetadata?

        switch self.rule
        {
        case .insertEditorFromGitHub(login: let login):
            guard
            let integration:any GitHub.Integration = server.github
            else
            {
                return .error("GitHub integration is not available.\n")
            }

            let restAPI:GitHub.Client<GitHub.OAuth> = .rest(app: integration.oauth,
                threads: server.context.threads,
                niossl: server.context.niossl,
                as: integration.agent)

            let user:GitHub.User
            do
            {
                user = try await restAPI.connect { try await $0.get(from: "/users/\(login)") }
            }
            catch let error as HTTP.StatusError
            {
                return .resource("GitHub: \(error)\n", status: error.code ?? 400)
            }

            let registered:Unidoc.UserSecrets = try await server.db.users.update(
                user: .init(github: user, initialLimit: server.db.policy.apiLimitPerReset),
                with: session)

            package = try await server.db.packages.insert(editor: registered.account,
                into: self.package,
                with: session)

        case .insertEditor(let editor):
            package = try await server.db.packages.insert(editor: editor,
                into: self.package,
                with: session)

        case .revokeEditor(let editor):
            package = try await server.db.packages.revoke(editor: editor,
                from: self.package,
                with: session)
        }

        if  let package:Unidoc.PackageMetadata
        {
            return .redirect(.seeOther("\(Unidoc.RulesEndpoint[package.symbol])"))
        }
        else
        {
            return .notFound("Failed to update package.\n")
        }
    }
}
