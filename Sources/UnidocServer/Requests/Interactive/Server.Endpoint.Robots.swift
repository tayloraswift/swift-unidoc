import HTTP
import UnidocPages

extension Server.Endpoint
{
    /// Serves the `robots.txt` file.
    struct Robots:Sendable
    {
        init()
        {
        }
    }
}
extension Server.Endpoint.Robots:PublicEndpoint
{
    func load(from server:Server.InteractiveState) -> ServerResponse?
    {
        .ok(.init(
            content: .string(server.robots),
            type: .text(.plain, charset: .utf8)))
    }
}
