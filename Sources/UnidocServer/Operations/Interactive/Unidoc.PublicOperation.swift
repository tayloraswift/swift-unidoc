import HTTP
import UnidocRender

extension Unidoc
{
    public
    protocol PublicOperation:InteractiveOperation
    {
        consuming
        func load(from server:Server,
            as format:RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
extension Unidoc.PublicOperation
{
    public consuming
    func load(with context:Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse?
    {
        try await self.load(from: context.server, as: context.format)
    }
}
