import HTTP
import Unidoc
import UnidocPages
import Media

extension Swiftinit.GlobalUplinkEndpoint
{
    enum Status
    {
        case enqueued
    }
}
extension Swiftinit.GlobalUplinkEndpoint.Status:HTTP.ServerResponseFactory
{
    func response(as _:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .enqueued: .redirect(.see(other: "/admin"))
        }
    }
}
