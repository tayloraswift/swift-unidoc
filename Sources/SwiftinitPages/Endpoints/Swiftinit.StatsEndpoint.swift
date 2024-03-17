import HTML
import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct StatsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
    {
        public
        let query:Unidoc.VertexQuery<Unidoc.LookupLimited>
        public
        var value:Unidoc.VertexOutput?

        @inlinable public
        init(query:Unidoc.VertexQuery<Unidoc.LookupLimited>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.StatsEndpoint:Swiftinit.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Swiftinit.Stats

    public static
    func response(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext<VertexCache>) throws -> HTTP.ServerResponse
    {
        let route:Unidoc.Route

        switch vertex
        {
        case .article(let vertex):  route = vertex.route
        case .decl(let vertex):     route = vertex.route
        case .foreign(let vertex):  route = vertex.route
        case .product(let vertex):  route = vertex.route

        case .culture(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.page.volume)
            let page:Swiftinit.Stats.ModulePage = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            return .ok(page.resource(format: context.format))

        case .global(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.page.volume)
            let page:Swiftinit.Stats.PackagePage = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            return .ok(page.resource(format: context.format))

        case .file(let vertex):
            throw Unidoc.VertexTypeError.reject(.file(vertex))
        }

        //  There is documentation for this vertex, but it doesn’t have any stats.
        return .redirect(.temporary("\(Swiftinit.Docs[context.page.volume, route])"))
    }
}
