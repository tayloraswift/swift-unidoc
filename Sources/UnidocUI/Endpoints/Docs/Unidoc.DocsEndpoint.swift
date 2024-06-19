import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct DocsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
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
extension Unidoc.DocsEndpoint:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .docs }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .docc }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .hist }
}
extension Unidoc.DocsEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Self

    public
    func success(
        vertex apex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.InternalPageContext,
        format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        let resource:HTTP.Resource

        switch apex
        {
        case .article(let apex):
            let sidebar:Unidoc.Sidebar<Self> = .module(
                volume: context.volume,
                tree: tree)
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:ArticlePage = try .init(sidebar: sidebar, cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .culture(let apex):
            let sidebar:Unidoc.Sidebar<Self> = .module(
                volume: context.volume,
                tree: tree)
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:ModulePage = .init(sidebar: sidebar, cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .decl(let apex):
            let sidebar:Unidoc.Sidebar<Self> = .module(
                volume: context.volume,
                tree: tree)
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:DeclPage = try .init(sidebar: sidebar, cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .file:
            throw Unidoc.VertexTypeError.file

        case .product(let apex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:ProductPage = .init(cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .foreign(let apex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:ForeignPage = try .init(cone: cone, apex: apex)
            resource = page.resource(format: format)

        case .landing(let apex):
            let cone:Unidoc.Cone = try .init(context, groups: groups, apex: apex)
            let page:PackagePage = .init(cone: cone, apex: apex)
            resource = page.resource(format: format)
        }

        return .ok(resource)
    }
}
