import HTTP
import UnidocRender

extension Unidoc
{
    public
    protocol InteractiveOperation:Sendable
    {
        consuming
        func load(from server:borrowing Server,
            with credentials:Credentials,
            as format:RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
