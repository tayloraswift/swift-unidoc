import HTTP

protocol UnrestrictedOperation:StatefulOperation
{
    func load(from services:Services) async throws -> ServerResponse?
}
extension UnrestrictedOperation
{
    func load(from services:Services,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        try await self.load(from: services)
    }
}
