import HTTP
import UnidocPages

protocol InteractiveEndpoint:Sendable
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int> { get }

    func load(from server:Server.InteractiveState,
        with cookies:Server.Cookies) async throws -> ServerResponse?
}
extension InteractiveEndpoint
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.other
    }
}
