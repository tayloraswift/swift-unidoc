import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Site
{
    @frozen public
    enum Blog
    {
    }
}
extension Site.Blog
{
}
extension Site.Blog:StaticRoot
{
    @inlinable public static
    var root:String { "articles" }
}
extension Site.Blog:VolumeRoot
{
    public static
    func response(
        vertex:consuming Volume.Vertex,
        groups:consuming [Volume.Group],
        tree:consuming Volume.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        if  case .article(let vertex) = vertex
        {
            let page:Site.Blog.Article = .init(context.page, vertex: vertex)
            return .ok(page.resource(assets: context.assets))
        }
        else
        {
            return .error("not an article!")
        }
    }
}
