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

extension Swiftinit.UserConfigEndpoint:RestrictedEndpoint
{
    func admit(user:Unidoc.Account, level:Unidoc.User.Level) -> Bool
    {
        switch level
        {
        case .administratrix:   true
        case .machine:          true
        case .human:            self.account == user
        }
    }

    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

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

        return .redirect(.see(other: "\(Swiftinit.Root.acct)"))
    }
}
