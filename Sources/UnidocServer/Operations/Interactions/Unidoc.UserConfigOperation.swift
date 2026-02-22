import HTTP
import MongoDB

extension Unidoc {
    struct UserConfigOperation: Sendable {
        let account: Unidoc.Account
        let update: Update

        private var rights: Unidoc.UserRights

        init(account: Unidoc.Account, update: Update) {
            self.account = account
            self.update = update

            self.rights = .init()
        }
    }
}

extension Unidoc.UserConfigOperation: Unidoc.RestrictedOperation {
    /// Everyone can use this endpoint, as long as they are authenticated. This endpoint can
    /// only modify the currently authenticated user, unless she is an admin.
    mutating func admit(user: Unidoc.UserRights) -> Bool {
        self.rights = user
        return true
    }

    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as _: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        let redirect: Unidoc.Account?

        switch self.update {
        case .generateKey(for: let account):

            if  self.account != account {
                guard case .administratrix = self.rights.level else {
                    return .forbidden("You can only generate keys for yourself!\n")
                }

                redirect = account
            } else {
                redirect = nil
            }

            guard
            let _: Unidoc.UserSecrets = try await db.users.scramble(
                secret: .apiKey,
                user: account
            ) else {
                return .notFound("No such user")
            }
        }

        return .redirect(.seeOther("\(Unidoc.UserSettingsEndpoint[redirect])"))
    }
}
