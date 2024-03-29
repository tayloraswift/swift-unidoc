import HTTP

protocol PublicEndpoint:InteractiveEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server,
        as format:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
}
extension PublicEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server,
        with _:Swiftinit.Cookies,
        as format:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await self.load(from: server, as: format)
    }
}
