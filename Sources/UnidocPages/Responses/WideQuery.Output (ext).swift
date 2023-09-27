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

        if  let master:Volume.Vertex = principal.master
        {
            let inliner:Inliner = .init(principal: master.id,
                volume: principal.names,
                repo: principal.repo)

            inliner.vertices.add(self.secondary)
            inliner.volumes.add(self.names)

            master.overview.map
            {
                inliner.outlines += $0.outlines
            }
            master.details.map
            {
                inliner.outlines += $0.outlines
            }

            //  Special case for Swiftinit blog posts.
            if  case .article(let master) = master,
                principal.names.symbol.package == "__swiftinit"
            {
                let page:Site.Blog.Article = .init(inliner, master: master)
                return .ok(page.resource())
            }

            let canonical:CanonicalVersion? = .init(principal: principal)
            let resource:ServerResource

            //  Note: noun tree won’t exist if the module contains no declarations.
            //  (For example, an `@_exported` shim.)
            switch master
            {
            case .article(let master):
                let page:Site.Docs.Article = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups,
                    nouns: principal.tree?.rows)
                resource = page.resource()

            case .culture(let master):
                let page:Site.Docs.Culture = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups,
                    nouns: principal.tree?.rows)
                resource = page.resource()

            case .decl(let master):
                let page:Site.Docs.Decl = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups,
                    nouns: principal.tree?.rows)
                resource = page.resource()

            case .file:
                //  We should never get this as principal output!
                throw WideQuery.OutputError.malformed

            case .meta(let master):
                let page:Site.Docs.Meta = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups)
                resource = page.resource()
            }

            return .ok(resource)
        }

        let inliner:Inliner = .init(principal: principal.names, repo: principal.repo)
            inliner.vertices.add(principal.matches)

        if  let choices:Site.Docs.MultipleFound = .init(inliner,
                matches: principal.matches)
        {
            return .multiple(choices.resource())
        }
        else
        {
            //  We currently don’t have any actual means of obtaining a type tree in this
            //  situation, but in theory, we could.
            let display:Site.Docs.NotFound = .init(inliner,
                nouns: principal.tree?.rows)

            return .notFound(display.resource())
        }
    }
}
