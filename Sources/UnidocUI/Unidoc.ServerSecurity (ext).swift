extension Unidoc.ServerSecurity
{
    func permissions(package:Unidoc.PackageMetadata, user:Unidoc.User?) -> Unidoc.Permissions
    {
        if  case .ignored = self
        {
            /// In development mode, everyone is an administratrix!
            return .init(global: user.map { _ in .administratrix }, rights: .owner)
        }

        if  let user:Unidoc.User
        {
            return .init(global: user.level, rights: .of(account: user.id,
                access: user.access,
                rulers: package.rulers))
        }
        else
        {
            return .init(global: nil, rights: .reader)
        }
    }
}
