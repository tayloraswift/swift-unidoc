import HTTP

extension Unidoc
{
    struct PackageMetadataSettingsOperation:Sendable
    {
        let account:Account?
        let package:Package
        let update:Update

        private
        var rights:UserRights

        init(account:Account?, package:Package, update:Update)
        {
            self.account = account
            self.package = package
            self.update = update
            self.rights = .init()
        }
    }
}
extension Unidoc.PackageMetadataSettingsOperation:Unidoc.RestrictedOperation
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
                rights: self.rights)
        {
            return rejection
        }

        let metadata:Unidoc.PackageMetadata?

        switch self.update
        {
        case .general(let settings):
            metadata = try await db.packages.set(settings: settings, of: self.package)

        case .media(let media):
            metadata = try await db.packages.set(media: media, of: self.package)

        case .build(let template):
            metadata = try await db.packages.set(build: template, of: self.package)
        }

        if  let metadata:Unidoc.PackageMetadata
        {
            return .redirect(.seeOther("\(Unidoc.RefsEndpoint[metadata.symbol])"))
        }
        else
        {
            //  Not completely unreachable, due to race conditions.
            return .notFound("No such package!")
        }
    }
}
