import HTTP
import MongoDB
import UnidocDB

extension Unidoc
{
    /// An endpoint that returns the MongoDB `explain` output for the base endpoint instead
    /// of running the actual query.
    struct LoadExplainedOperation<Query>:Sendable where Query:Mongo.PipelineQuery
    {
        private
        let query:Query

        init(query:Query)
        {
            self.query = query
        }
    }
}
extension Unidoc.LoadExplainedOperation:Unidoc.PublicOperation
{
    func load(from server:Unidoc.Server,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let db:Unidoc.DB = try await server.db.session()
        return .ok(.init(content: .init(
            body: .string(try await db.explain(query: self.query)),
            type: .text(.plain, charset: .utf8))))
    }
}
