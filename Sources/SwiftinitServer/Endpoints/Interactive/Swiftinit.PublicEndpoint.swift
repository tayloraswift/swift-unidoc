import HTTP

extension Swiftinit
{
    protocol PublicEndpoint:InteractiveEndpoint
    {
        consuming
        func load(from server:borrowing Swiftinit.Server,
            as format:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
extension Swiftinit.PublicEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server,
        with _:Swiftinit.Credentials,
        as format:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await self.load(from: server, as: format)
    }
}
