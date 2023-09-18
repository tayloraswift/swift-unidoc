import HTTP

protocol UnrestrictedOperation:StatefulOperation
{
    func load(from server:ServerState) async throws -> ServerResponse?
}
extension UnrestrictedOperation
{
    func load(from server:ServerState,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        try await self.load(from: server)
    }
}
