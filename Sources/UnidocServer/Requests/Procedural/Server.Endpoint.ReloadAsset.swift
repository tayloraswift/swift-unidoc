import HTTP

extension Server.Endpoint
{
    enum ReloadAsset:Sendable
    {
        case all
    }
}
extension Server.Endpoint.ReloadAsset:ProceduralEndpoint
{
    func perform(on server:Server.ProceduralState) async -> ServerResponse
    {
        await server.cache.clear()
        return .ok("OK")
    }
}
