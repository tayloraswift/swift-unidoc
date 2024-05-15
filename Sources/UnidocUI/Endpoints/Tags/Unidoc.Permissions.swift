extension Unidoc
{
    struct Permissions
    {
        let global:Unidoc.User.Level?
        let rights:Unidoc.PackageRights

        private
        init(global:Unidoc.User.Level?, rights:Unidoc.PackageRights)
        {
            self.global = global
            self.rights = rights
        }
    }
}
extension Unidoc.Permissions
{
    /// Indicates whether information restricted to editors should be displayed. This returns
    /// true for package owners and for administratrices regardless of their relationship to the
    /// package.
    var editor:Bool
    {
        self.global == .administratrix || self.rights >= .editor
    }

    /// Indicates whether information restricted to owners should be displayed. This returns
    /// true for administratrices regardless of their relationship to the package.
    var owner:Bool
    {
        self.global == .administratrix || self.rights >= .owner
    }
}
extension Unidoc.Permissions
{
    init(package:Unidoc.PackageMetadata, user:Unidoc.User?)
    {
        guard
        let user:Unidoc.User
        else
        {
            self.init(global: nil, rights: .reader)
            return
        }
        if  let owner:Unidoc.Account = package.repo?.account
        {
            self.init(global: user.level, rights: .of(account: user.id,
                access: user.access,
                owner: owner))
        }
        else
        {
            self.init(global: user.level, rights: .reader)
        }
    }
}
