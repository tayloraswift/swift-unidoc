import HTTP
import MongoDB

extension Unidoc {
    /// A ``DocsOperation`` is a little bit smarter than the average ``PipelineOperation``, as
    /// it can follow redirects and map searchbot trails.
    struct DocsOperation: ExplainableOperation, Sendable {
        let query: VertexQuery<LookupAdjacent>

        init(query: VertexQuery<LookupAdjacent>) {
            self.query = query
        }
    }
}
extension Unidoc.DocsOperation: Unidoc.InteractiveOperation {
    func load(with context: Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse? {
        let db: Unidoc.DB = try await context.server.db.session()

        guard
        let output: Unidoc.VertexOutput = try await db.query(
            with: self.query,
            on: Unidoc.DocsEndpoint.replica
        ) else {
            return .notFound("Snapshot not found.\n")
        }

        coverage:
        if  let apex: Unidoc.AnyVertex = output.principalVertex {
            //  This response is going to be a 200 OK, so count it as such.

            //  Historical docs do not receive page-granularity statistics.
            guard output.principalVolume.latest,
            //  Check if this request is from someone we trust enough to count page-granularity
            //  statistics for.
            let privilege: Unidoc.ClientPrivilege = context.request.privilege else {
                break coverage
            }

            //  C declarations do not receive page-granularity statistics.
            if  case .decl(let apex) = apex,
                apex.route.cdecl {
                break coverage
            }

            switch privilege {
            case .majorSearchEngine(let vendor, verified: _):
                context.server.paint(
                    with: .init(
                        searchbot: vendor,
                        volume: output.principalVolume.id,
                        vertex: self.query.vertex,
                        time: context.request.accepted
                    )
                )

            case .barbie(_, verified: _):
                //  Ignore for now, until we have a good way to exclude hits from the
                //  package owners themselves.
                break
            }
        } else {
            guard
            let _: Unidoc.ClientPrivilege = context.request.privilege else {
                //  This is an expensive operation, so we will not do it for random bots and
                //  crawlers.
                break coverage
            }

            if  let redirect: Unidoc.RedirectOutput = try await db.redirect(
                    exported: self.query.vertex,
                    from: output.principalVolume.id
                ) {
                return redirect.response(as: context.format)
            }

            if  let redirect: Unidoc.RedirectOutput = try await db.redirect(
                    visited: self.query.vertex,
                    in: output.principalVolume.id.package
                ) {
                return redirect.response(as: context.format)
            }
        }

        let endpoint: Unidoc.DocsEndpoint = .init(query: self.query)
        return try endpoint.response(from: output, as: context.format)
    }
}
