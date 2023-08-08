import HTTPServer
import MongoDB
import UnidocDatabase
import URI

struct QueryOperation<Query>:Sendable
    where Query:DatabaseQuery, Query.Output:ServerResponseFactory<URI>
{
    let requested:URI
    var explain:Bool
    var query:Query

    init(explain:Bool, query:Query, uri:URI)
    {
        self.requested = uri
        self.explain = explain
        self.query = query
    }
}
extension QueryOperation:DatabaseOperation
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

        if  let output:Query.Output = try await database.execute(
                query: self.query,
                with: session)
        {
            return try output.response(for: self.requested)
        }
        else
        {
            return nil
        }
    }
}
