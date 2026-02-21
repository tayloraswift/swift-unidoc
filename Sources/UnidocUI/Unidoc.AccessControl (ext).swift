extension Unidoc.AccessControl {
    func permissions(
        package: Unidoc.PackageMetadata,
        user: Unidoc.User?
    ) -> Unidoc.Permissions {
        if  case .ignored = self {
            return .init(global: .developer, rights: .owner)
        }

        if  let user: Unidoc.User {
            return .init(
                global: .authenticated(user.level), rights: .of(
                    account: user.id,
                    access: user.access,
                    rulers: package.rulers
                )
            )
        } else {
            return .init(global: .guest, rights: .reader)
        }
    }
}
