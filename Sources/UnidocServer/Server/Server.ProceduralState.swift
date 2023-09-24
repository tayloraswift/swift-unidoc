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
    func respond(to requests:AsyncStream<Server.ProceduralRequest>) async throws
    {
        for await request:Server.ProceduralRequest in requests
        {
            try Task.checkCancellation()

            do
            {
                request.promise.succeed(try await request.operation.perform(on: self, with: 0))
            }
            catch let error
            {
                request.promise.fail(error)
            }
        }
    }
}
