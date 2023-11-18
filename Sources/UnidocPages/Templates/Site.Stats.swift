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
            throw Volume.LookupOutputError.malformed

        case .culture(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let page:Module = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex)
            resource = page.resource(assets: context.assets)

        case .decl:
            throw Volume.LookupOutputError.malformed

        case .file:
            //  We should never get this as principal output!
            throw Volume.LookupOutputError.malformed

        case .foreign:
            throw Volume.LookupOutputError.malformed

        case .global(_):
            //  TODO: implement me
            throw Volume.LookupOutputError.malformed
        }

        return .ok(resource)
    }
}
