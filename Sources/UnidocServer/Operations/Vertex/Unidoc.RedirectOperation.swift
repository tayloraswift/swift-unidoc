import HTTP
import MongoDB

extension Unidoc {
    struct RedirectOperation<Query>: ExplainableOperation, Sendable
        where Query: Mongo.PipelineQuery,
        Query.Iteration == Mongo.Single<Unidoc.RedirectOutput> {
        let query: Query
    }
}
extension Unidoc.RedirectOperation: Unidoc.InteractiveOperation {
    consuming func load(
        with context: Unidoc.ServerResponseContext
    ) async throws -> HTTP.ServerResponse? {
        let db: Unidoc.DB = try await context.server.db.session()

        guard
        let output: Unidoc.RedirectOutput = try await db.query(
            with: self.query,
            on: .nearest
        ) else {
            return .notFound("Volume not found.\n")
        }

        return output.response(as: context.format)
    }
}
