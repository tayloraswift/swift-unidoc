import HTTP
import UnidocRender

extension Unidoc
{
    struct PackageWebhookOperation:Sendable
    {
        init()
        {
        }
    }
}
extension Unidoc.PackageWebhookOperation:Unidoc.PublicOperation
{
    func load(from server:borrowing Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        .noContent
    }
}
