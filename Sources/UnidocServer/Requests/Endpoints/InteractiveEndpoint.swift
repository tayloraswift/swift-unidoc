import HTTP
import UnidocPages

protocol InteractiveEndpoint:Sendable
{
    func load(from server:Server.InteractiveState,
        with cookies:Server.Cookies) async throws -> ServerResponse?
}
