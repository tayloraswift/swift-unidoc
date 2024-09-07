import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocUI

extension Unidoc
{
    struct PackageBuildOperation:MeteredOperation
    {
        let account:Account
        let symbol:Symbol.PackageAtRef
        let action:Unidoc.BuildForm.Action

        var rights:Unidoc.UserRights

        init(account:Account, symbol:Symbol.PackageAtRef, action:Unidoc.BuildForm.Action)
        {
            self.account = account
            self.symbol = symbol
            self.action = action

            self.rights = .init()
        }
    }
}
extension Unidoc.PackageBuildOperation
{
    init(account:Unidoc.Account, form:Unidoc.BuildForm)
    {
        self.init(account: account, symbol: form.symbol, action: form.action)
    }
}
extension Unidoc.PackageBuildOperation:Unidoc.RestrictedOperation
{
    func load(from server:Unidoc.Server,
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        guard
        let outputs:Unidoc.EditionOutput = try await db.edition(named: self.symbol),
        let edition:Unidoc.EditionMetadata = outputs.edition
        else
        {
            return .notFound("No such edition")
        }

        if  let rejection:HTTP.ServerResponse = try await db.authorize(
                package: outputs.package,
                loading: edition.id.package,
                account: self.account,
                rights: self.rights)
        {
            return rejection
        }

        //  From now on, use canonical names
        let name:Symbol.PackageAtRef = .init(package: outputs.package.symbol, ref: edition.name)

        switch self.action
        {
        case .submit:
            _ = try await db.pendingBuilds.submitBuild(id: edition.id, name: name)

        case .cancel:
            guard try await db.pendingBuilds.cancelBuild(id: edition.id)
            else
            {
                return .resource("Cannot cancel a build that has already started", status: 409)
            }
        }

        return .redirect(.seeOther("\(Unidoc.RefsEndpoint[name.package])"))
    }
}
