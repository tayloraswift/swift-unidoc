import HTML
import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Swiftinit.Stats:Swiftinit.VolumeRoot
{
    public static
    func response(
        vertex:consuming Unidoc.Vertex,
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
            let sidebar:Swiftinit.Sidebar<Self>? = .package(volume: context.page.volume)
            let page:Module = .init(context.page,
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
            let sidebar:Swiftinit.Sidebar<Self>? = .package(volume: context.page.volume)
            let page:Package = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(format: context.format)
        }

        return .ok(resource)
    }
}
