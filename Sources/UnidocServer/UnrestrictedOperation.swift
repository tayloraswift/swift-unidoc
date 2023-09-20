import HTTP

protocol UnrestrictedOperation:InteractiveOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
}
extension UnrestrictedOperation
{
    func load(from server:Server.State,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        try await self.load(from: server)
    }
}
