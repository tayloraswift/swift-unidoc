import HTTP
import MongoDB

extension Swiftinit
{
    struct UserConfigEndpoint:Sendable
    {
        let account:Unidoc.Account
        let update:Update

        init(account:Unidoc.Account, update:Update)
        {
            self.account = account
            self.update = update
        }
    }
}

extension Swiftinit.UserConfigEndpoint:Swiftinit.RestrictedEndpoint
{
    /// Everyone can use this endpoint, as long as they are authenticated. This endpoint can
    /// only modify the currently authenticated user.
    func admit(level:Unidoc.User.Level) -> Bool { true }

    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        switch self.update
        {
        case .generateKey:
            guard
            let _:Unidoc.UserSecrets = try await server.db.users.scramble(secret: .apiKey,
                user: self.account,
                with: session)
            else
            {
                return .notFound("No such user")
            }
        }

        return .redirect(.seeOther("\(Swiftinit.Root.account)"))
    }
}
