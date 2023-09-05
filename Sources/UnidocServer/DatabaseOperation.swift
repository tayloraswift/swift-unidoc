import HTTPServer

protocol DatabaseOperation:StatefulOperation
{
    func load(from database:Services.Database) async throws -> ServerResponse?
}
extension DatabaseOperation
{
    func load(from services:Services,
        with _:Server.Request.Cookies) async throws -> ServerResponse?
    {
        try await self.load(from: services.database)
    }
}
