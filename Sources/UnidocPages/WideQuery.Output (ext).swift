import HTTP
import UnidocQueries
import UnidocRecords
import URI

extension WideQuery.Output:ServerResponseFactory
{
    public
    func response(for _:URI) throws -> ServerResponse
    {
        guard let principal:WideQuery.Output.Principal = self.principal
        else
        {
            return .resource(.init(.none,
                content: .string("Snapshot not found."),
                type: .text(.plain, charset: .utf8)))
        }

        if  let master:Volume.Vertex = principal.master
        {
            let inliner:Inliner = .init(principal: master.id,
                names: principal.names,
                repo: principal.repo)

            inliner.vertices.add(self.secondary)
            inliner.names.add(self.names)

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
                principal.names.package == "__swiftinit"
            {
                let page:Site.Blog.Article = .init(inliner, master: master)
                return .resource(page.rendered())
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
                resource = page.rendered()

            case .culture(let master):
                let page:Site.Docs.Culture = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups,
                    nouns: principal.tree?.rows)
                resource = page.rendered()

            case .decl(let master):
                let page:Site.Docs.Decl = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups,
                    nouns: principal.tree?.rows)
                resource = page.rendered()

            case .file:
                //  We should never get this as principal output!
                throw WideQuery.OutputError.malformed

            case .meta(let master):
                let page:Site.Docs.Meta = .init(inliner,
                    canonical: canonical,
                    master: master,
                    groups: principal.groups)
                resource = page.rendered()
            }

            return .resource(resource)
        }
        else
        {
            let inliner:Inliner = .init(principal: principal.names, repo: principal.repo)
                inliner.vertices.add(principal.matches)

            if  let disambiguation:Site.Docs.Disambiguation = .init(inliner,
                    matches: principal.matches,
                    nouns: principal.tree?.rows ?? [])
            {
                return .resource(disambiguation.rendered())
            }
        }

        return .resource(.init(.none,
            content: .string("Volume not found."),
            type: .text(.plain, charset: .utf8)))
    }
}
