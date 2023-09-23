import HTTP
import Media
import MD5
import MongoDB
import UnidocDB
import UnidocPages
import URI

extension Server.Operation
{
    struct Pipeline<Query>:Sendable
        where Query:DatabaseQuery, Query.Output:ServerResponseFactory
    {
        /// If nil, the query will be explained instead of executed. If non-nil, this field
        /// will be passed to the query’s output type, which may influence the response it
        /// produces.
        let output:AcceptType?
        let query:Query
        let uri:URI
        let tag:MD5?

        init(output:AcceptType?,
            query:Query,
            uri:URI,
            tag:MD5? = nil)
        {
            self.output = output
            self.query = query
            self.uri = uri
            self.tag = tag
        }
    }
}
extension Server.Operation.Pipeline:InteractiveOperation
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.query
    }
}
extension Server.Operation.Pipeline:UnrestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
    {
        try await self.load(
            from: server.db.unidoc,
            with: try await .init(from: server.db.sessions))
    }

    private
    func load(from db:UnidocDatabase,
        with session:Mongo.Session) async throws -> ServerResponse?
    {
        guard
        let accept:AcceptType = self.output
        else
        {
            let explanation:String = try await db.explain(
                query: self.query,
                with: session)

            return .ok(.init(
                content: .string(explanation),
                type: .text(.plain, charset: .utf8)))
        }

        guard
        let output:Query.Output = try await db.execute(query: self.query, with: session)
        else
        {
            return nil
        }

        switch try output.response(as: accept)
        {
        case .redirect(let redirect, cookies: let cookies):
            return .redirect(redirect, cookies: cookies)

        case .multiple(var resource):
            resource.optimize(tag: self.tag)
            return .multiple(resource)

        case .ok(var resource):
            resource.optimize(tag: self.tag)
            return .ok(resource)

        case let other:
            return other
        }
    }
}
