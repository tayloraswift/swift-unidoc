import HTML
import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Site
{
    @frozen public
    enum Stats
    {
    }
}
extension Site.Stats:StaticRoot
{
    @inlinable public static
    var root:String { "stats" }
}
extension Site.Stats:VolumeRoot
{
    public static
    func response(
        vertex:consuming Volume.Vertex,
        groups:consuming [Volume.Group],
        tree:consuming Volume.TypeTree?,
        with context:IdentifiableResponseContext) throws -> HTTP.ServerResponse
    {
        let resource:HTTP.Resource

        switch vertex
        {
        case .article:
            throw Volume.VertexTypeError.article

        case .culture(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .package(volume: context.page.volume)
            let page:Module = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(assets: context.assets)

        case .decl:
            throw Volume.VertexTypeError.decl

        case .file:
            throw Volume.VertexTypeError.file

        case .foreign:
            throw Volume.VertexTypeError.foreign

        case .global(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .package(volume: context.page.volume)
            let page:Package = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(assets: context.assets)
        }

        return .ok(resource)
    }
}
