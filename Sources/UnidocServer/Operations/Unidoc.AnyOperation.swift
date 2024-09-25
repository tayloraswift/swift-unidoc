import HTTP
import MD5
import MongoDB
import UnidocAssets
import UnidocRender

extension Unidoc
{
    @frozen public
    enum AnyOperation:Sendable
    {
        /// Runs with no ordering guarantees. Suspensions while serving the request might
        /// interleave with other requests.
        case unordered(any Unidoc.InteractiveOperation)
        /// Runs on the update loop, which is ordered with respect to other updates.
        case update(any Unidoc.ProceduralOperation)

        case syncHTML(any Unidoc.StatusBearingPage & Sendable)
        case syncLoad(Unidoc.Cache<Unidoc.Asset>.Request)
        case sync(HTTP.ServerResponse)
    }
}
extension Unidoc.AnyOperation
{
    static func sync(error message:String, status:UInt = 400) -> Self
    {
        .sync(.resource(.init(content: .init(
                body: .string(message),
                type: .text(.plain, charset: .utf8))),
            status: 400))
    }

    static func sync(redirect:HTTP.Redirect) -> Self
    {
        .sync(.redirect(redirect, cookies: []))
    }

    static func pipeline<Base>(_ endpoint:Base) -> Self where Base:Unidoc.VertexEndpoint
    {
        .unordered(Unidoc.VertexOperation<Base>.init(base: endpoint))
    }

    static func pipeline<Base>(_ endpoint:Base) -> Self where
        Base:HTTP.ServerEndpoint<Unidoc.RenderFormat>,
        Base:Mongo.PipelineEndpoint,
        Base:Sendable
    {
        .unordered(Unidoc.PipelineOperation<Base>.init(base: endpoint))
    }
}
