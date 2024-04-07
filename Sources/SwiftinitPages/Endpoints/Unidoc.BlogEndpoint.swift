import HTTP
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords

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
extension Unidoc.BlogEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Swiftinit.Blog

    public
    func success(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.RelativePageContext,
        format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        switch vertex
        {
        case .article(let vertex):
            let mesh:Swiftinit.Mesh = try .init(context, groups: groups, apex: vertex)
            let page:Swiftinit.Blog.ArticlePage = .init(mesh: mesh, apex: vertex)
            return .ok(page.resource(format: format))

        case let unexpected:
            throw Unidoc.VertexTypeError.reject(unexpected)
        }
    }
}
