import HTTP

protocol PublicEndpoint:InteractiveEndpoint
{
    func load(from server:isolated Server) async throws -> HTTP.ServerResponse?
}
extension PublicEndpoint
{
    func load(from server:isolated Server,
        with _:Server.Cookies) async throws -> HTTP.ServerResponse?
    {
        try await self.load(from: server)
    }
}
