extension Unidoc.ServerSecurity
{
    func permissions(package:Unidoc.PackageMetadata, user:Unidoc.User?) -> Unidoc.Permissions
    {
        if  case .ignored = self
        {
            return .init(global: user.map { _ in .administratrix }, rights: .owner)
        }

        guard
        let user:Unidoc.User
        else
        {
            return .init(global: nil, rights: .reader)
        }

        if  let owner:Unidoc.Account = package.repo?.account
        {
            return .init(global: user.level, rights: .of(account: user.id,
                access: user.access,
                owner: owner))
        }
        else
        {
            return .init(global: user.level, rights: .reader)
        }
    }
}
