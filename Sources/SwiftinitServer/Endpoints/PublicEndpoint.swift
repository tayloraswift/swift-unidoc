import HTTP

protocol PublicEndpoint:InteractiveEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
}
extension PublicEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server,
        with _:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
    {
        try await self.load(from: server)
    }
}
