import HTTP
import MongoDB

extension Unidoc
{
    /// A ``DocsOperation`` is a little bit smarter than the average ``PipelineOperation``, as
    /// it can follow redirects and map searchbot trails.
    struct DocsOperation:ExplainableOperation, Sendable
    {
        let query:VertexQuery<LookupAdjacent>

        init(query:VertexQuery<LookupAdjacent>)
        {
            self.query = query
        }
    }
}
extension Unidoc.DocsOperation:Unidoc.InteractiveOperation
{
    func load(with context:Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse?
    {
        let db:Unidoc.DB = try await context.server.db.session()

        guard
        let output:Unidoc.VertexOutput = try await db.query(
            with: self.query,
            on: Unidoc.DocsEndpoint.replica)
        else
        {
            return .notFound("Snapshot not found.\n")
        }

        coverage:
        if  let apex:Unidoc.AnyVertex = output.principal.vertex
        {
            //  This response is probably going to be a 200 OK, so count it as such.
            guard
            let privilege:Unidoc.ClientPrivilege = context.request.privilege
            else
            {
                //  This request is not from someone we trust enough to count for
                //  page-granularity statistics.
                break coverage
            }

            //  Historical docs do not receive page-granularity statistics.
            let latest:Unidoc.Edition

            if  output.principal.volume.latest
            {
                latest = output.principal.volume.id
            }
            else
            {
                break coverage
            }

            //  C declarations do not receive page-granularity statistics.
            if  case .decl(let apex) = apex,
                apex.route.cdecl
            {
                break coverage
            }

            switch privilege
            {
            case .majorSearchEngine(let vendor, verified: _):
                context.server.paint(with: .init(
                    searchbot: vendor,
                    volume: latest,
                    shoot: apex.shoot))

            case .barbie(_, verified: _):
                //  Ignore for now, until we have a good way to exclude hits from the
                //  package owners themselves.
                break
            }
        }
        else
        {
            guard
            let _:Unidoc.ClientPrivilege = context.request.privilege
            else
            {
                //  This is an expensive operation, so we will not do it for random bots and
                //  crawlers.
                break coverage
            }

            let trail:Unidoc.SearchbotTrail = .init(
                trunk: output.principal.volume.id.package,
                shoot: self.query.vertex)

            if  let tile:Unidoc.SearchbotCoverage = try await db.searchbotGrid.find(id: trail),
                let redirect:Unidoc.RedirectOutput = try await db.query(
                    with: Unidoc.InternalRedirectQuery<Unidoc.Shoot>(
                        volume: tile.ok,
                        lookup: self.query.vertex),
                    on: .nearest)
            {
                return redirect.response(as: context.format)
            }
        }

        let endpoint:Unidoc.DocsEndpoint = .init(query: self.query)
        return try endpoint.response(from: output, as: context.format)
    }
}
