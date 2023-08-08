import HTTPServer
import UnidocQueries
import UnidocRecords
import URI

extension WideQuery.Output:ServerResponseFactory
{
    public
    func response(for _:URI) throws -> ServerResponse
    {
        guard self.principal.count == 1
        else
        {
            return .resource(.init(.none,
                content: .text("Snapshot not found."),
                type: .text(.plain, charset: .utf8)))
        }

        let principal:WideQuery.Output.Principal = self.principal[0]
        let resource:ServerResource

        if  let master:Record.Master = principal.master
        {
            let inliner:Inliner = .init(principal: master.id, trunk: principal.trunk)
                inliner.masters.add(self.secondary)
                inliner.trunks.add(self.zones)

            switch master
            {
            case .article(let master):
                let article:Site.Guides.Article = .init(inliner,
                    master: master,
                    groups: principal.groups)
                resource = article.rendered()

            case .culture(let master):
                let culture:Site.Docs.Culture = .init(inliner,
                    master: master,
                    groups: principal.groups)
                resource = culture.rendered()

            case .decl(let master):
                let decl:Site.Docs.Decl = .init(inliner,
                    master: master,
                    groups: principal.groups)
                resource = decl.rendered()

            case .file:
                //  We should never get this as principal output!
                throw WideQuery.OutputError.malformed
            }
        }
        else if
            let disambiguation:Site.Docs.Disambiguation = .init(
                matches: principal.matches,
                in: principal.trunk)
        {
            resource = disambiguation.rendered()
        }
        else
        {
            throw WideQuery.OutputError.malformed
        }

        return .resource(resource)
    }
}
