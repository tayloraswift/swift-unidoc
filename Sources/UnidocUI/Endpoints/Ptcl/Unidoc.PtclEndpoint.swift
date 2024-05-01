import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Unidoc
{
    @frozen public
    struct PtclEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
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
extension Unidoc.PtclEndpoint:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .ptcl }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .ptcl }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .ptcl }
}
extension Unidoc.PtclEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Self

    public
    func success(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.PeripheralPageContext,
        format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        let route:Unidoc.Route

        switch vertex
        {
        case .article(let vertex):  route = vertex.route
        case .culture(let vertex):  route = vertex.route
        case .foreign(let vertex):  route = vertex.route
        case .product(let vertex):  route = vertex.route
        case .landing(let vertex):  route = vertex.route

        case .decl(let vertex):
            guard case .protocol = vertex.phylum
            else
            {
                route = vertex.route
                break
            }

            let sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>? = .module(
                volume: context.volume,
                tree: tree)

            let conformers:Unidoc.ConformingTypes = try .init(context,
                groups: groups,
                bias: vertex.culture)

            let page:ConformersPage = try .init(
                sidebar: sidebar,
                vertex: vertex,
                halo: conformers)

            return .ok(page.resource(format: format))

        case .file(let vertex):
            throw Unidoc.VertexTypeError.reject(.file(vertex))
        }

        //  There is documentation for this vertex, but it is not a protocol.
        return .redirect(.temporary("\(Unidoc.DocsEndpoint[context.volume, route])"))
    }
}
