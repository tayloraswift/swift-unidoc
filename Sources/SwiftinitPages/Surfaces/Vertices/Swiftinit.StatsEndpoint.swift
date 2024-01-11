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
    struct StatsEndpoint:Mongo.SingleOutputEndpoint
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
        let resource:HTTP.Resource

        switch vertex
        {
        case .culture(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.page.volume)
            let page:Swiftinit.Stats.ModulePage = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(format: context.format)

        case .global(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.page.volume)
            let page:Swiftinit.Stats.PackagePage = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(format: context.format)

        case let unexpected:
            throw Unidoc.VertexTypeError.reject(unexpected)
        }

        return .ok(resource)
    }
}
