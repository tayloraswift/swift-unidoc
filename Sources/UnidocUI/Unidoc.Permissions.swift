extension Unidoc
{
    struct Permissions
    {
        private
        let global:Global
        let rights:Unidoc.PackageRights

        init(global:Global, rights:Unidoc.PackageRights)
        {
            self.global = global
            self.rights = rights
        }
    }
}
extension Unidoc.Permissions
{
    /// Indicates whether the user is logged in. In local development mode, this returns true.
    var authenticated:Bool
    {
        switch self.global
        {
        case .authenticated:    true
        case .developer:        true
        case .guest:            false
        }
    }

    /// Indicates if the server is enforcing permissions. In local development mode, this
    /// returns false.
    var enforced:Bool
    {
        switch self.global
        {
        case .authenticated: true
        case .developer:     false
        case .guest:         true
        }
    }

    /// Indicates whether information restricted to editors should be displayed. This returns
    /// true for package owners and for administratrices regardless of their relationship to the
    /// package.
    var editor:Bool
    {
        self.admin || self.rights >= .editor
    }

    /// Indicates whether information restricted to owners should be displayed. This returns
    /// true for administratrices regardless of their relationship to the package.
    var owner:Bool
    {
        self.admin || self.rights >= .owner
    }

    var admin:Bool
    {
        switch self.global
        {
        case .authenticated(.administratrix):   true
        case .authenticated(_):                 false
        case .developer:                        true
        case .guest:                            false
        }
    }
}
