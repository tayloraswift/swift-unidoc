import HTTP
import Media
import UnidocQueries
import UnidocRecords
import URI

extension WideQuery.Output:HTTP.ServerResponseFactory
{
    public consuming
    func response(with assets:StaticAssets, as _:AcceptType?) throws -> HTTP.ServerResponse
    {
        guard let principal:WideQuery.Output.Principal = (copy self).principal
        else
        {
            return .notFound(.init(
                content: .string("Snapshot not found."),
                type: .text(.plain, charset: .utf8)))
        }

        guard
        let vertex:Volume.Vertex = principal.vertex
        else
        {
            let context:VersionedPageContext = .init(
                principal: principal.volume,
                repo: principal.repo)

            context.vertices.add(principal.matches)

            if  let choices:Site.Docs.MultipleFound = .init(context,
                    matches: principal.matches)
            {
                return .multiple(choices.resource(assets: assets))
            }
            else
            {
                //  We currently don’t have any actual means of obtaining a type tree in this
                //  situation, but in theory, we could.
                let display:Site.Docs.NotFound = .init(context,
                    sidebar: principal.tree?.rows)

                return .notFound(display.resource(assets: assets))
            }
        }

        let context:VersionedPageContext = .init(principal: vertex.id,
            volume: principal.volume,
            repo: principal.repo)
        ;
        {
            context.vertices.add($0.vertices)
            context.volumes.add($0.volumes)
        } (consume self)

        vertex.overview.map
        {
            context.outlines += $0.outlines
        }
        vertex.details.map
        {
            context.outlines += $0.outlines
        }

        //  Special case for Swiftinit blog posts.
        if  case .article(let vertex) = vertex,
            principal.volume.symbol.package == "__swiftinit"
        {
            let page:Site.Blog.Article = .init(context, vertex: vertex)
            return .ok(page.resource(assets: assets))
        }

        let canonical:CanonicalVersion? = .init(principal: principal)
        let sidebar:[Volume.Noun]? = principal.tree?.rows


        let resource:HTTP.Resource

        //  Note: noun tree won’t exist if the module contains no declarations.
        //  (For example, an `@_exported` shim.)
        switch vertex
        {
        case .article(let vertex):
            let groups:GroupSections = .init(context,
                groups: principal.groups,
                bias: vertex.id,
                mode: nil)
            let page:Site.Docs.Article = .init(context,
                canonical: canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: assets)

        case .culture(let vertex):
            let groups:GroupSections = .init(context,
                groups: principal.groups,
                bias: vertex.id,
                mode: nil)
            let page:Site.Docs.Culture = .init(context,
                canonical: canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: assets)

        case .decl(let vertex):
            let groups:GroupSections = .init(context,
                requirements: vertex.requirements,
                superforms: vertex.superforms,
                generics: vertex.signature.generics.parameters,
                groups: principal.groups,
                bias: vertex.culture,
                mode: .decl(vertex.phylum, vertex.kinks))
            let page:Site.Docs.Decl = .init(context,
                canonical: canonical,
                sidebar: sidebar,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: assets)

        case .file:
            //  We should never get this as principal output!
            throw WideQuery.OutputError.malformed

        case .foreign(let vertex):
            let groups:GroupSections = .init(context,
                groups: principal.groups,
                bias: nil,
                mode: .decl(vertex.phylum, vertex.kinks))
            let page:Site.Docs.Foreign = .init(context,
                canonical: canonical,
                vertex: vertex,
                groups: groups)
            resource = page.resource(assets: assets)

        case .global:
            let groups:GroupSections = .init(context,
                groups: principal.groups,
                bias: vertex.id,
                mode: .meta)
            let page:Site.Docs.Meta = .init(context,
                canonical: canonical,
                groups: groups)
            resource = page.resource(assets: assets)
        }

        return .ok(resource)
    }
}
