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
    func load(from server:borrowing Unidoc.Server,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let explanation:String = try await session.explain(
            database: server.db.unidoc.id,
            query: self.query)

        return .ok(.init(content: .init(
            body: .string(explanation),
            type: .text(.plain, charset: .utf8))))
    }
}
