import HTTPServer

protocol DatalessOperation:Sendable
{
    func load() throws -> ServerResponse?
}
