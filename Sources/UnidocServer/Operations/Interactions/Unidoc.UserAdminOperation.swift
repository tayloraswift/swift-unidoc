import HTTP
import MongoDB

extension Unidoc
{
    /// A `UserAdminOperation` is similar to an ordinary ``UserSettingsEndpoint``, except
    /// it allows querying information about a user other than the currently authenticated user.
    ///
    /// Because ``UserSettingsEndpoint`` runs as a public ``LoadOptimizedOperation``, **allowing
    /// it to query other users would be a security hazard**, even if the endpoint itself later
    /// redacts restricted queries, as this would still allow an attacker to observe the
    /// behavior of the query itself.
    struct UserAdminOperation:Sendable
    {
        let account:Unidoc.Account

        init(account:Unidoc.Account)
        {
            self.account = account
        }
    }
}
extension Unidoc.UserAdminOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        var endpoint:Unidoc.UserSettingsEndpoint = .init(query: .another(self.account))
        try await endpoint.pull(from: server.db.unidoc.id, with: session)
        return endpoint.response(as: format, admin: true)
    }
}
