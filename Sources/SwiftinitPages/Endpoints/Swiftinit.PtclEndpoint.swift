import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Swiftinit
{
    @frozen public
    struct PtclEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
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
    public
    typealias VertexLayer = Swiftinit.Ptcl

    public
    func success(
        vertex:consuming Unidoc.AnyVertex,
        groups:consuming [Unidoc.AnyGroup],
        tree:consuming Unidoc.TypeTree?,
        with context:Unidoc.PeripheralPageContext,
        format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        let route:Unidoc.Route

        switch vertex
        {
        case .article(let vertex):  route = vertex.route
        case .culture(let vertex):  route = vertex.route
        case .foreign(let vertex):  route = vertex.route
        case .product(let vertex):  route = vertex.route
        case .global(let vertex):   route = vertex.route

        case .decl(let vertex):
            guard case .protocol = vertex.phylum
            else
            {
                route = vertex.route
                break
            }

            let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? = .module(
                volume: context.volume,
                tree: tree)

            let conformers:Swiftinit.ConformingTypes = try .init(context,
                groups: groups,
                bias: vertex.culture)

            let page:Swiftinit.Ptcl.ConformersPage = try .init(
                sidebar: sidebar,
                vertex: vertex,
                halo: conformers)

            return .ok(page.resource(format: format))

        case .file(let vertex):
            throw Unidoc.VertexTypeError.reject(.file(vertex))
        }

        //  There is documentation for this vertex, but it is not a protocol.
        return .redirect(.temporary("\(Swiftinit.Docs[context.volume, route])"))
    }
}
