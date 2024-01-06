import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct BlogEndpoint:Mongo.SingleOutputEndpoint
    {
        public
        let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>
        public
        var value:Unidoc.VertexOutput?

        @inlinable public
        init(query:Unidoc.VertexQuery<Unidoc.LookupAdjacent>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.BlogEndpoint:Swiftinit.VertexEndpoint, HTTP.ServerEndpoint
{
    public static
    func response(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        if  case .article(let vertex) = vertex
        {
            let page:Swiftinit.Blog.ArticlePage = .init(context.page, vertex: vertex)
            return .ok(page.resource(format: context.format))
        }
        else
        {
            return .error("not an article!")
        }
    }
}
