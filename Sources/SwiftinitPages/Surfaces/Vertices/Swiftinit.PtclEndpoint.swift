import HTTP
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct PtclEndpoint:Mongo.SingleOutputEndpoint
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
extension Swiftinit.PtclEndpoint:Swiftinit.VertexEndpoint, HTTP.ServerEndpoint
{
    public static
    func response(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        switch vertex
        {
        case .decl(let vertex):
            let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? = .module(
                volume: context.page.volume,
                tree: tree)

            let groups:GroupSections = .init(context.page,
                organizing: consume groups,
                vertex: vertex,
                bias: vertex.culture,
                mode: .decl(vertex.phylum, vertex.kinks))

            let page:Swiftinit.PtclPage = try .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)

            return .ok(page.resource(format: context.format))

        case let unexpected:
            throw Unidoc.VertexTypeError.reject(unexpected)
        }
    }
}
