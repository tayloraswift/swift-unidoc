import HTTP
import MongoDB

extension Swiftinit
{
    struct UserRenderEndpoint:Sendable
    {
        let request:Request
        let account:Unidoc.Account
        let apiKey:Int64

        init(request:Request, account:Unidoc.Account, apiKey:Int64)
        {
            self.request = request
            self.account = account
            self.apiKey = apiKey
        }
    }
}
extension Swiftinit.UserRenderEndpoint:PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        as _:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let remaining:Int = try await server.db.users.charge(apiKey: self.apiKey,
            user: self.account,
            with: session)
        else
        {
            return .resource("Inactive or nonexistent API key", status: 429)
        }

        return .ok(.init(
            headers: .init(canonical: nil, rateLimit: .init(remaining: remaining)),
            content: .binary([]),
            type: .text(.html, charset: .utf8),
            gzip: false,
            hash: nil))
    }
}
