import HTTP

extension Server
{
    @dynamicMemberLookup
    struct ProceduralState
    {
        private
        let server:Server

        init(server:Server)
        {
            self.server = server
        }
    }
}
extension Server.ProceduralState
{
    subscript<T>(dynamicMember keyPath:KeyPath<Server, T>) -> T
    {
        self.server[keyPath: keyPath]
    }
}
extension Server.ProceduralState
{
    mutating
    func respond(to requests:AsyncStream<Server.Request<any ProceduralEndpoint>>) async throws
    {
        for await request:Server.Request<any ProceduralEndpoint> in requests
        {
            try Task.checkCancellation()

            do
            {
                request.promise.succeed(try await request.endpoint.perform(on: self,
                    with: request.cookies))
            }
            catch let error
            {
                request.promise.fail(error)
            }
        }
    }
}
