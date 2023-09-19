import HTTP

protocol DatabaseOperation:StatefulOperation
{
    func load(from db:Server.DB) async throws -> ServerResponse?
}
extension DatabaseOperation where Self:UnrestrictedOperation
{
    func load(from server:ServerState) async throws -> ServerResponse?
    {
        try await self.load(from: server.db)
    }
}
extension DatabaseOperation where Self:RestrictedOperation
{
    func load(from server:ServerState) async throws -> ServerResponse?
    {
        try await self.load(from: server.db)
    }
}
