import HTTP
import MongoDB

extension Unidoc
{
    /// An operation that runs a MongoDB pipeline query and returns the result as an HTTP
    /// response.
    struct PipelineOperation<Endpoint>:Sendable where
        Endpoint:Mongo.PipelineEndpoint,
        Endpoint:HTTP.ServerEndpoint<Unidoc.RenderFormat>,
        Endpoint:Sendable
    {
        /// The base endpoint to invoke.
        private
        var base:Endpoint

        init(base:Endpoint)
        {
            self.base = base
        }
    }
}
extension Unidoc.PipelineOperation:Unidoc.ExplainableOperation
{
    var query:Endpoint.Query { self.base.query }
}
extension Unidoc.PipelineOperation:Unidoc.InteractiveOperation
{
    consuming
    func load(with context:Unidoc.ServerResponseContext) async throws -> HTTP.ServerResponse?
    {
        try await self.base.pull(from: try await context.server.db.session())
        return try self.base.response(as: context.format)
    }
}
