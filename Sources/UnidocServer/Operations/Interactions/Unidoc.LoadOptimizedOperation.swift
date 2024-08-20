import HTTP
import MD5
import Media
import MongoDB
import UnidocDB
import UnidocRender
import URI

extension Unidoc
{
    /// An endpoint that optimizes the output of the base endpoint’s ``HTTP.ServerResponse``.
    struct LoadOptimizedOperation<Base>:Sendable
        where   Base:HTTP.ServerEndpoint<Unidoc.RenderFormat>,
                Base:Mongo.PipelineEndpoint,
                Base:Sendable
    {
        /// An optional cache tag used to optimize the response.
        private
        let etag:MD5?
        /// The base endpoint to invoke.
        private
        var base:Base

        init(base:Base, etag:MD5? = nil)
        {
            self.etag = etag
            self.base = base
        }
    }
}
extension Unidoc.LoadOptimizedOperation:Unidoc.PublicOperation
{
    consuming
    func load(from server:Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await self.base.pull(from: try await server.db.session())

        let etag:MD5? = self.etag

        switch try self.base.response(as: format)
        {
        case .redirect(let redirect, cookies: let cookies):
            return .redirect(redirect, cookies: cookies)

        case .resource(var resource, status: let status):
            if  status == 200 || status == 300
            {
                resource.optimize(tag: etag)
            }
            return .resource(resource, status: status)
        }
    }
}
