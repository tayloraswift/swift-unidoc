import HTTP
import MD5
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import URI

extension Swiftinit
{
    /// An endpoint that optimizes the output of the base endpoint’s ``HTTP.ServerResponse``.
    struct OptimizingEndpoint<Base>:Sendable
        where   Base:HTTP.ServerEndpoint<Swiftinit.RenderFormat>,
                Base:Mongo.PipelineEndpoint,
                Base:Sendable
    {
        /// An `accept-type` to propogate to the base endpoint, which may influence the response
        /// it produces. Overrides the request’s `accept-type` if non-nil.
        private
        let accept:HTTP.AcceptType?
        /// An optional cache tag used to optimize the response.
        private
        let etag:MD5?
        /// The base endpoint to invoke.
        private
        var base:Base

        init(accept:HTTP.AcceptType? = nil,
            etag:MD5? = nil,
            base:Base)
        {
            self.accept = accept
            self.etag = etag
            self.base = base
        }
    }
}
extension Swiftinit.OptimizingEndpoint:PublicEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server,
        as format:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        try await self.base.pull(from: server.db.unidoc.id, with: session)

        let (accept, etag):(HTTP.AcceptType?, MD5?) = { ($0.accept, $0.etag) } (self)

        var format:Swiftinit.RenderFormat = format
        if  let accept:HTTP.AcceptType
        {
            format.accept = accept
        }

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
