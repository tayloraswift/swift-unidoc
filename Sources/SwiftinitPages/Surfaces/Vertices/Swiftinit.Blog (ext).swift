import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Swiftinit.Blog:Swiftinit.VolumeRoot
{
    public static
    func response(
        vertex:consuming Unidoc.Vertex,
        groups:consuming [Unidoc.Group],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        if  case .article(let vertex) = vertex
        {
            let page:ArticlePage = .init(context.page, vertex: vertex)
            return .ok(page.resource(format: context.format))
        }
        else
        {
            return .error("not an article!")
        }
    }
}
