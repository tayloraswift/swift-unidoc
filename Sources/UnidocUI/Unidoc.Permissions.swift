extension Unidoc
{
    struct Permissions
    {
        let global:Unidoc.User.Level?
        let rights:Unidoc.PackageRights

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
