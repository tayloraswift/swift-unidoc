import HTML
import HTTP
import Media
import UnidocQueries
import UnidocRecords

extension Swiftinit.Docs:Swiftinit.VolumeRoot
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
        case .article(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let groups:GroupSections = .init(context.page,
                organizing: consume groups,
                bias: vertex.id,
                mode: nil)

            let page:Article = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(format: context.format)

        case .culture(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let groups:GroupSections = .init(context.page,
                organizing: consume groups,
                bias: vertex.id,
                mode: nil)
            let page:Module = .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(format: context.format)

        case .decl(let vertex):
            let sidebar:HTML.Sidebar<Self>? = .module(volume: context.page.volume,
                tree: tree)
            let groups:GroupSections = .init(context.page,
                organizing: consume groups,
                vertex: vertex,
                bias: vertex.culture,
                mode: .decl(vertex.phylum, vertex.kinks))
            let page:Decl = try .init(context.page,
                canonical: context.canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(format: context.format)

        case .file:
            throw Unidoc.VertexTypeError.file

        case .foreign(let vertex):
            let groups:GroupSections = .init(context.page,
                organizing: consume groups,
                bias: nil,
                mode: .decl(vertex.phylum, vertex.kinks))
            let page:Foreign = try .init(context.page,
                canonical: context.canonical,
                vertex: vertex,
                groups: groups)
            resource = page.resource(format: context.format)

        case .global(let vertex):
            let groups:GroupSections = .init(context.page,
                organizing: consume groups,
                bias: vertex.id,
                mode: .meta)
            let page:Package = .init(context.page,
                canonical: context.canonical,
                vertex: vertex,
                groups: groups)
            resource = page.resource(format: context.format)
        }

        return .ok(resource)
    }
}
