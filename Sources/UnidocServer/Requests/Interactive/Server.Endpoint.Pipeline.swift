import HTTP
import Media
import MD5
import MongoDB
import UnidocDB
import UnidocPages
import URI

extension Server.Endpoint
{
    struct Pipeline<Query>:Sendable
        where Query:DatabaseQuery, Query.Output:ServerResponseFactory<StaticAssets>
    {
        /// If nil, the query will be explained instead of executed. If non-nil, this field
        /// will be passed to the query’s output type, which may influence the response it
        /// produces.
        let output:AcceptType?
        let query:Query
        let tag:MD5?

        init(output:AcceptType?,
            query:Query,
            tag:MD5? = nil)
        {
            self.output = output
            self.query = query
            self.tag = tag
        }
    }
}
extension Server.Endpoint.Pipeline:PublicEndpoint
{
    func load(from server:Server.InteractiveState) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let accept:AcceptType = self.output
        else
        {
            let explanation:String = try await server.db.unidoc.explain(
                query: self.query,
                with: session)

            return .ok(.init(
                content: .string(explanation),
                type: .text(.plain, charset: .utf8)))
        }

        guard
        let output:Query.Output = try await server.db.unidoc.execute(
            query: self.query,
            with: session)
        else
        {
            return nil
        }

        switch try output.response(with: server.assets, as: accept)
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
