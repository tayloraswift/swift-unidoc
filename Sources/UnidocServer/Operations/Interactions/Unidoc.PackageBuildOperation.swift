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
    init(account:Unidoc.Account, build:SymbolicParameters)
    {
        self.init(account: account,
            action: build.ref.map
            {
                .submitSymbolic(.init(package: build.package, ref: $0))
            } ?? .cancelSymbolic(build.package),
            redirect: build.package)
    }
    init(account:Unidoc.Account, build:DirectParameters)
    {
        self.init(account: account,
            action: build.request.map { .submit(build.package, $0) } ?? .cancel(build.package),
            redirect: build.selector.package)
    }
}
extension Unidoc.PackageBuildOperation:Unidoc.RestrictedOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let package:Unidoc.Package
        let request:Unidoc.BuildRequest?

        switch self.action
        {
        case .submit(let id, let build):
            package = id
            request = build

        case .cancel(let id):
            package = id
            request = nil

        case .cancelSymbolic(let symbol):
            guard
            let metadata:Unidoc.PackageMetadata = try await server.db.unidoc.package(
                named: symbol,
                with: session)
            else
            {
                return .notFound("No such package")
            }

            package = metadata.id
            request = nil

        case .submitSymbolic(let symbol):
            guard
            let metadata:Unidoc.EditionOutput = try await server.db.unidoc.edition(
                package: symbol.package,
                version: .name(symbol.ref),
                with: session),
            let edition:Unidoc.Edition = metadata.edition?.id
            else
            {
                return .notFound("No such edition")
            }

            package = metadata.package.id
            request = .id(edition, force: true)
        }

        if  let rejection:HTTP.ServerResponse = try await server.authorize(
                package: package,
                account: self.account,
                rights: self.rights,
                with: session)
        {
            return rejection
        }

        if  let request:Unidoc.BuildRequest
        {
            _ = try await server.db.packageBuilds.submitBuild(request: request,
                package: package,
                with: session)
        }
        else if try await server.db.packageBuilds.cancelBuild(
                package: package,
                with: session)
        {
        }
        else
        {
            return .resource("Cannot cancel a build that has already started", status: 409)
        }

        return .redirect(.seeOther("\(Unidoc.TagsEndpoint[self.redirect])"))
    }
}
