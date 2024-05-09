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
        let build:Parameters

        var privileges:Unidoc.User.Level

        init(account:Account, build:Parameters)
        {
            self.account = account
            self.build = build

            self.privileges = .human
        }
    }
}
extension Unidoc.PackageBuildOperation:Unidoc.RestrictedOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        if  let rejection:HTTP.ServerResponse = try await server.authorize(
                package: self.build.package,
                account: self.account,
                level: self.privileges,
                with: session)
        {
            return rejection
        }

        if  let request:Unidoc.BuildRequest = self.build.request
        {
            _ = try await server.db.packageBuilds.submitBuild(request: request,
                package: self.build.package,
                with: session)
        }
        else if try await server.db.packageBuilds.cancelBuild(
                package: self.build.package,
                with: session)
        {
        }
        else
        {
            return .resource("Cannot cancel a build that has already started", status: 409)
        }

        return .redirect(.seeOther("\(Unidoc.TagsEndpoint[self.build.selector.package])"))
    }
}
