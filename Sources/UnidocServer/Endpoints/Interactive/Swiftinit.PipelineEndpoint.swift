import HTTP
import Media
import MD5
import MongoDB
import UnidocDB
import UnidocPages
import URI

extension Swiftinit
{
    struct PipelineEndpoint<Query>:Sendable
        where   Query:Mongo.PipelineQuery,
                Query.Iteration.Stride == Never?,
                Query.Iteration.Batch == Query.Iteration.BatchElement?,
                Query.Iteration.BatchElement:HTTP.ServerResponseFactory<Unidoc.RenderFormat>
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
extension Swiftinit.PipelineEndpoint:PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
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
        let output:Query.Iteration.BatchElement = try await server.db.unidoc.execute(
            query: self.query,
            with: session)
        else
        {
            return nil
        }

        switch try output.response(as: server.format(accept))
        {
        case .redirect(let redirect, cookies: let cookies):
            return .redirect(redirect, cookies: cookies)

        case .resource(var resource, status: let status):
            if  status == 200 || status == 300
            {
                resource.optimize(tag: self.tag)
            }
            return .resource(resource, status: status)
        }
    }
}
