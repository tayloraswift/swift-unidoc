import GitHubAPI
import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocUI

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
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        if  let rejection:HTTP.ServerResponse = try await db.authorize(
                loading: self.package,
                account: self.account,
                rights: self.rights,
                require: .owner)
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
                niossl: server.clientIdentity,
                on: .singleton,
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

            let registered:Unidoc.UserSecrets = try await db.users.update(
                user: .init(github: user, initialLimit: server.db.settings.apiLimitPerReset))

            package = try await db.packages.insert(editor: registered.account,
                into: self.package)

        case .insertEditor(let editor):
            package = try await db.packages.insert(editor: editor,
                into: self.package)

        case .revokeEditor(let editor):
            package = try await db.packages.revoke(editor: editor,
                from: self.package)
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
