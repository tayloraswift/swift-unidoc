import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnidocRender

extension Unidoc
{
    @frozen public
    struct BlogEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
    {
        public
        let query:VertexQuery<LookupAdjacent>
        public
        var value:VertexOutput?

        @inlinable public
        init(query:VertexQuery<LookupAdjacent>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.BlogEndpoint:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .blog }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .blog }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .blog }
}
extension Unidoc.BlogEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Self

    public
    func success(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.RelativePageContext,
        format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        switch vertex
        {
        case .article(let vertex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: vertex)
            let page:ArticlePage = .init(cone: cone, apex: vertex)
            return .ok(page.resource(format: format))

        case let unexpected:
            throw Unidoc.VertexTypeError.reject(unexpected)
        }
    }
}
