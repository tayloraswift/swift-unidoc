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
    public static
    func response(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.Group],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        let resource:HTTP.Resource

        switch vertex
        {
        case .article:
            throw Unidoc.VertexTypeError.article

        case .culture(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.page.volume)
            let page:Swiftinit.Stats.ModulePage = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(format: context.format)

        case .decl:
            throw Unidoc.VertexTypeError.decl

        case .file:
            throw Unidoc.VertexTypeError.file

        case .foreign:
            throw Unidoc.VertexTypeError.foreign

        case .product:
            throw Unidoc.VertexTypeError.product

        case .global(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Stats>? = .package(
                volume: context.page.volume)
            let page:Swiftinit.Stats.PackagePage = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(format: context.format)
        }

        return .ok(resource)
    }
}
