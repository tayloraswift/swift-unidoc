import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct BlogEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
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
    public
    typealias VertexLayer = Swiftinit.Blog

    public static
    func response(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext<VertexCache>) throws -> HTTP.ServerResponse
    {
        switch vertex
        {
        case .article(let vertex):
            let mesh:Swiftinit.Mesh = try .init(context.page, groups: groups, apex: vertex)
            let page:Swiftinit.Blog.ArticlePage = .init(mesh: mesh, apex: vertex)
            return .ok(page.resource(format: context.format))

        case let unexpected:
            throw Unidoc.VertexTypeError.reject(unexpected)
        }
    }
}
