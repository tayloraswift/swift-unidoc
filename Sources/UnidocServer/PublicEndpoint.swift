import HTTP

protocol PublicEndpoint:InteractiveEndpoint
{
    func load(from server:Server.InteractiveState) async throws -> ServerResponse?
}
extension PublicEndpoint
{
    func load(from server:Server.InteractiveState,
        with _:Server.Cookies) async throws -> ServerResponse?
    {
        try await self.load(from: server)
    }
}
