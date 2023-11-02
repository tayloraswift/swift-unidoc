import HTTP
import UnidocPages

protocol InteractiveEndpoint:Sendable
{
    func load(from server:isolated Server,
        with cookies:Server.Cookies) async throws -> HTTP.ServerResponse?
}
