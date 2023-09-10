import HTTP
import UnidocPages

protocol StatefulOperation:Sendable
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int> { get }

    func load(from services:Services,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
}
extension StatefulOperation
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.other
    }
}
