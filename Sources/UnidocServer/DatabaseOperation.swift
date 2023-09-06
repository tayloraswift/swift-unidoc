import HTTPServer

protocol DatabaseOperation:StatefulOperation
{
    func load(from database:Services.Database) async throws -> ServerResponse?
}
extension DatabaseOperation where Self:UnrestrictedOperation
{
    func load(from services:Services) async throws -> ServerResponse?
    {
        try await self.load(from: services.database)
    }
}
extension DatabaseOperation where Self:RestrictedOperation
{
    func load(from services:Services) async throws -> ServerResponse?
    {
        try await self.load(from: services.database)
    }
}
