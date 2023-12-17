import HTTP
import Media
import Unidoc

extension Swiftinit.GlobalUplinkEndpoint
{
    enum Status
    {
        case enqueued
    }
}
extension Swiftinit.GlobalUplinkEndpoint.Status:HTTP.ServerResponseFactory
{
    consuming
    func response(as _:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .enqueued: .redirect(.see(other: "/admin"))
        }
    }
}
