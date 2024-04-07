import HTML
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
extension Unidoc.StatsEndpoint:Unidoc.VertexEndpoint, HTTP.ServerEndpoint
{
    public
    typealias VertexLayer = Swiftinit.Stats

    public
    func success(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.RelativePageContext,
        format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
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
                volume: context.volume)
            let page:Swiftinit.Stats.ModulePage = .init(context,
                sidebar: sidebar,
                vertex: vertex)
            return .ok(page.resource(format: format))

        case .global(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.volume)
            let page:Swiftinit.Stats.PackagePage = .init(context,
                sidebar: sidebar,
                vertex: vertex)
            return .ok(page.resource(format: format))

        case .file(let vertex):
            throw Unidoc.VertexTypeError.reject(.file(vertex))
        }

        //  There is documentation for this vertex, but it doesn’t have any stats.
        return .redirect(.temporary("\(Swiftinit.Docs[context.volume, route])"))
    }
}
