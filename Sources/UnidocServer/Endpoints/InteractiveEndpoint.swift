import HTTP
import UnidocPages

protocol InteractiveEndpoint:Sendable
{
    func load(from server:borrowing Swiftinit.Server,
        with cookies:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
}
