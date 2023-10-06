import HTTP
import Media
import UnidocQueries
import UnidocRecords
import URI

extension WideQuery.Output:ServerResponseFactory
{
    public
    func response(as _:AcceptType?) throws -> ServerResponse
    {
        guard let principal:WideQuery.Output.Principal = self.principal
        else
        {
            return .notFound(.init(
                content: .string("Snapshot not found."),
                type: .text(.plain, charset: .utf8)))
        }

        if  let vertex:Volume.Vertex = principal.vertex
        {
            let context:VersionedPageContext = .init(principal: vertex.id,
                volume: principal.volume,
                repo: principal.repo)

            context.vertices.add(self.vertices)
            context.volumes.add(self.volumes)

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
                return .ok(page.resource())
            }

            let canonical:CanonicalVersion? = .init(principal: principal)
            let resource:ServerResource

            //  Note: noun tree won’t exist if the module contains no declarations.
            //  (For example, an `@_exported` shim.)
            switch vertex
            {
            case .article(let vertex):
                let page:Site.Docs.Article = .init(context,
                    canonical: canonical,
                    sidebar: principal.tree?.rows,
                    vertex: vertex,
                    groups: principal.groups)
                resource = page.resource()

            case .culture(let vertex):
                let page:Site.Docs.Culture = .init(context,
                    canonical: canonical,
                    sidebar: principal.tree?.rows,
                    vertex: vertex,
                    groups: principal.groups)
                resource = page.resource()

            case .decl(let vertex):
                let page:Site.Docs.Decl = .init(context,
                    canonical: canonical,
                    sidebar: principal.tree?.rows,
                    vertex: vertex,
                    groups: principal.groups)
                resource = page.resource()

            case .file:
                //  We should never get this as principal output!
                throw WideQuery.OutputError.malformed

            case .foreign(let vertex):
                let page:Site.Docs.Foreign = .init(context,
                    canonical: canonical,
                    vertex: vertex,
                    groups: principal.groups)
                resource = page.resource()

            case .global:
                let page:Site.Docs.Meta = .init(context,
                    canonical: canonical,
                    groups: principal.groups)
                resource = page.resource()
            }

            return .ok(resource)
        }

        let context:VersionedPageContext = .init(
            principal: principal.volume,
            repo: principal.repo)

        context.vertices.add(principal.matches)

        if  let choices:Site.Docs.MultipleFound = .init(context,
                matches: principal.matches)
        {
            return .multiple(choices.resource())
        }
        else
        {
            //  We currently don’t have any actual means of obtaining a type tree in this
            //  situation, but in theory, we could.
            let display:Site.Docs.NotFound = .init(context,
                sidebar: principal.tree?.rows)

            return .notFound(display.resource())
        }
    }
}