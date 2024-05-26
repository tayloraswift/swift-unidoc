import HTTP
import UnidocRender

extension Unidoc
{
    public
    protocol InteractiveOperation:Sendable
    {
        consuming
        func load(from server:borrowing Server,
            with state:LoginState,
            as format:RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
