import HTTP
import MongoDB

extension Unidoc
{
    struct VertexOperation<Endpoint>:Sendable where Endpoint:VertexEndpoint, Endpoint:Sendable
    {
        let base:Endpoint

        init(base:Endpoint)
        {
            self.base = base
        }
    }
}
extension Unidoc.VertexOperation:Unidoc.ExplainableOperation
{
    var query:Endpoint.Query { self.base.query }
}
extension Unidoc.VertexOperation:Unidoc.InteractiveOperation
{
    func load(with context:Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse?
    {
        let db:Unidoc.DB = try await context.server.db.session()

        guard
        let output:Unidoc.VertexOutput = try await db.query(
            with: self.base.query,
            on: Endpoint.replica)
        else
        {
            return .notFound("Snapshot not found.\n")
        }

        return try self.base.response(from: output, as: context.format)
    }
}
