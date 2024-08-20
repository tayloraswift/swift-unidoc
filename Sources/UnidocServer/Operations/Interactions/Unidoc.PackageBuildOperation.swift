import HTTP
import MongoDB
import UnidocUI
import Symbols
import UnidocDB

extension Unidoc
{
    struct PackageBuildOperation:MeteredOperation
    {
        let account:Account
        let action:Action
        let redirect:Symbol.Package

        var rights:Unidoc.UserRights

        init(account:Account, action:Action, redirect:Symbol.Package)
        {
            self.account = account
            self.action = action
            self.redirect = redirect

            self.rights = .init()
        }
    }
}
extension Unidoc.PackageBuildOperation
{
    init(account:Unidoc.Account, build:DirectParameters)
    {
        self.init(account: account,
            action: build.request.map { .submit(build.package, $0) } ?? .cancel(build.package),
            redirect: build.symbols.package)
    }
}
extension Unidoc.PackageBuildOperation:Unidoc.RestrictedOperation
{
    func load(from server:Unidoc.Server,
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let metadata:Unidoc.PackageMetadata?
        let package:Unidoc.Package
        let request:Unidoc.BuildRequest<Void>?

        switch self.action
        {
        case .submit(let id, let build):
            metadata = nil
            package = id
            request = build

        case .cancel(let id):
            metadata = nil
            package = id
            request = nil

        case .cancelSymbolic(let symbol):
            metadata = try await db.package(named: symbol)

            guard
            let metadata:Unidoc.PackageMetadata
            else
            {
                return .notFound("No such package")
            }

            package = metadata.id
            request = nil

        case .submitSymbolic(let symbol):
            guard
            let outputs:Unidoc.EditionOutput = try await db.edition(
                package: symbol.package,
                version: .name(symbol.ref)),
            let edition:Unidoc.Edition = outputs.edition?.id
            else
            {
                return .notFound("No such edition")
            }

            metadata = outputs.package
            package = outputs.package.id
            request = .init(version: .id(edition), rebuild: true)
        }

        if  let rejection:HTTP.ServerResponse = try await db.authorize(
                package: metadata,
                loading: package,
                account: self.account,
                rights: self.rights)
        {
            return rejection
        }

        if  let request:Unidoc.BuildRequest<Void>
        {
            _ = try await db.packageBuilds.submitBuild(request: request, package: package)
        }
        else if try await db.packageBuilds.cancelBuild(package: package)
        {
        }
        else
        {
            return .resource("Cannot cancel a build that has already started", status: 409)
        }

        return .redirect(.seeOther("\(Unidoc.RefsEndpoint[self.redirect])"))
    }
}
