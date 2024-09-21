import HTTP
import MD5
import Media
import MongoDB
import UnidocDB
import UnidocRender
import URI

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
extension Unidoc.PipelineOperation:Unidoc.PublicOperation
{
    consuming
    func load(from server:Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await self.base.pull(from: try await server.db.session())
        return try self.base.response(as: format)
    }
}
