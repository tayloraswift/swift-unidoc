import HTTP
import UnidocRender

extension Unidoc
{
    public
    protocol PublicOperation:InteractiveOperation
    {
        consuming
        func load(from server:borrowing Server,
            as format:RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
extension Unidoc.PublicOperation
{
    public consuming
    func load(from server:borrowing Unidoc.Server,
        with _:Unidoc.Credentials,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await self.load(from: server, as: format)
    }
}