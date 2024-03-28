import HTTP
import MongoDB
import UnidocDB

extension Swiftinit
{
    /// An endpoint that returns the MongoDB `explain` output for the base endpoint instead
    /// of running the actual query.
    struct ExplanatoryEndpoint<Query>:Sendable where Query:Mongo.PipelineQuery
    {
        private
        let query:Query

        init(query:Query)
        {
            self.query = query
        }
    }
}
extension Swiftinit.ExplanatoryEndpoint:Swiftinit.PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        as _:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let explanation:String = try await session.explain(
            database: server.db.unidoc.id,
            query: self.query)

        return .ok(.init(
            content: .string(explanation),
            type: .text(.plain, charset: .utf8),
            gzip: false))
    }
}
