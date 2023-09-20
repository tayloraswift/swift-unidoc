import HTTP
import UnidocPages

protocol InteractiveOperation:Sendable
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int> { get }

    func load(from server:Server.State,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
}
extension InteractiveOperation
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.other
    }
}
