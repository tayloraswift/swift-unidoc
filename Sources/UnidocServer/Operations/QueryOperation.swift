import HTTPServer
import MD5
import MongoDB
import UnidocDatabase
import URI

struct QueryOperation<Query>:Sendable
    where Query:DatabaseQuery, Query.Output:ServerResponseFactory<URI>
{
    let explain:Bool
    let query:Query
    let uri:URI
    let tag:MD5?

    init(explain:Bool, query:Query, uri:URI, tag:MD5? = nil)
    {
        self.explain = explain
        self.query = query
        self.uri = uri
        self.tag = tag
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
                content: .string(explanation),
                type: .text(.plain, charset: .utf8)))
        }

        guard   let output:Query.Output = try await database.execute(
                    query: self.query,
                    with: session)
        else
        {
            return nil
        }

        switch try output.response(for: self.uri)
        {
        case .redirect(let redirect):
            return .redirect(redirect)

        case .resource(var resource):
            resource.optimize(tag: self.tag)
            return .resource(resource)
        }
    }
}
