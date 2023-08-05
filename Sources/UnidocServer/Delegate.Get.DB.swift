import HTML
import HTTPServer
import MongoDB
import UnidocDatabase
import UnidocQueries
import UnidocRecords
import URI

extension Delegate.Get
{
    struct DB:Sendable
    {
        let requested:URI

        var canonical:Bool
        var explain:Bool
        var query:DeepQuery

        init(canonical:Bool, explain:Bool, query:DeepQuery, uri:URI)
        {
            self.requested = uri

            self.canonical = canonical
            self.explain = explain
            self.query = query
        }
    }
}
extension Delegate.Get.DB
{
    func load(from database:Database, pool:Mongo.SessionPool) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: pool)

        if  self.explain
        {
            let explanation:String = try await database.explain(
                query: self.query,
                with: session)

            return .resource(.init(.one(canonical: nil),
                content: .text(explanation),
                type: .text(.plain, charset: .utf8)))
        }

        let outputs:[DeepQuery.Output] = try await database.execute(
            query: self.query,
            with: session)

        guard outputs.count == 1
        else
        {
            return nil
        }

        let output:DeepQuery.Output = outputs[0]

        guard output.principal.count == 1
        else
        {
            return nil
        }

        let principal:DeepQuery.Output.Principal = output.principal[0]
        let resource:ServerResource

        if  let master:Record.Master = principal.master
        {
            let inliner:Inliner = .init(principal: master.id, zone: principal.zone)
                inliner.masters.add(output.secondary)
                inliner.zones.add(output.zones)

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
                return nil
            }
        }
        else if
            let disambiguation:Site.Docs.Disambiguation = .init(
                matches: principal.matches,
                in: principal.zone)
        {
            resource = disambiguation.rendered()
        }
        else
        {
            return nil
        }

        return .resource(resource)
    }
}
