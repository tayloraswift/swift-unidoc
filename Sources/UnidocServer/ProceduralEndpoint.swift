import HTTP

protocol ProceduralEndpoint:Sendable
{
    func perform(on server:Server.ProceduralState,
        with ticket:Int64) async throws -> ServerResponse
}
