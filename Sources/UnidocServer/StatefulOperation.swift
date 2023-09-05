import HTTPServer

protocol StatefulOperation:Sendable
{
    func load(from services:Services,
        with cookies:Server.Request.Cookies) async throws -> ServerResponse?
}
