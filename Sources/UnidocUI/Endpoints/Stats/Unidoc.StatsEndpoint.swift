import HTML
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
    struct StatsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
    {
        public
        let query:VertexQuery<LookupLimited>
        public
        var value:VertexOutput?

        @inlinable public
        init(query:VertexQuery<LookupLimited>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.StatsEndpoint:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .stats }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .stats }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .stats }
}
extension Unidoc.StatsEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Self

    public
    func success(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.InternalPageContext,
        format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        let route:Unidoc.Route

        switch vertex
        {
        case .article(let vertex):  route = vertex.route
        case .decl(let vertex):     route = vertex.route
        case .foreign(let vertex):  route = vertex.route
        case .product(let vertex):  route = vertex.route

        case .culture(let vertex):
            let sidebar:Unidoc.Sidebar<Self> = .package(volume: context.volume)
            let page:ModulePage = .init(context, sidebar: sidebar, vertex: vertex)
            return .ok(page.resource(format: format))

        case .landing(let vertex):
            let sidebar:Unidoc.Sidebar<Self> = .package(volume: context.volume)
            let page:PackagePage = .init(context, sidebar: sidebar, vertex: vertex)
            return .ok(page.resource(format: format))

        case .file(let vertex):
            throw Unidoc.VertexTypeError.reject(.file(vertex))
        }

        //  There is documentation for this vertex, but it doesn’t have any stats.
        return .redirect(.temporary("\(Unidoc.DocsEndpoint[context.volume, route])"))
    }
}
