import HTML
import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Site
{
    @frozen public
    enum Docs
    {
    }
}
extension Site.Docs:StaticRoot
{
    @inlinable public static
    var root:String { "docs" }
}
extension Site.Docs:VolumeRoot
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
        case .article(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let groups:GroupSections = .init(context.page,
                groups: consume groups,
                bias: vertex.id,
                mode: nil)

            let page:Article = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: context.assets)

        case .culture(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let groups:GroupSections = .init(context.page,
                groups: consume groups,
                bias: vertex.id,
                mode: nil)
            let page:Module = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: context.assets)

        case .decl(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let groups:GroupSections = .init(context.page,
                requirements: vertex.requirements,
                superforms: vertex.superforms,
                generics: vertex.signature.generics.parameters,
                groups: consume groups,
                bias: vertex.culture,
                mode: .decl(vertex.phylum, vertex.kinks))
            let page:Decl = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: context.assets)

        case .file:
            //  We should never get this as principal output!
            throw Volume.LookupOutputError.malformed

        case .foreign(let vertex):
            let groups:GroupSections = .init(context.page,
                groups: consume groups,
                bias: nil,
                mode: .decl(vertex.phylum, vertex.kinks))
            let page:Foreign = .init(context.page,
                canonical: context.canonical,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: context.assets)

        case .global(let vertex):
            let groups:GroupSections = .init(context.page,
                groups: consume groups,
                bias: vertex.id,
                mode: .meta)
            let page:Package = .init(context.page,
                canonical: context.canonical,
                groups: groups)
            resource = page.resource(assets: context.assets)
        }

        return .ok(resource)
    }
}
