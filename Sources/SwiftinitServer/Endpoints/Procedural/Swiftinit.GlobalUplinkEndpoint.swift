import MongoDB

extension Swiftinit
{
    struct GlobalUplinkEndpoint:Sendable
    {
        let queue:Bool

        init(queue:Bool)
        {
            self.queue = queue
        }
    }
}
extension Swiftinit.GlobalUplinkEndpoint:NonblockingEndpoint
{
    func enqueue(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> Status
    {
        .enqueued
    }

    func perform(on server:borrowing Swiftinit.Server,
        session:Mongo.Session,
        status:Status) async
    {
        do
        {
            try await server.db.unidoc.rebuildVolumes(queue: self.queue, with: session)
        }
        catch let error
        {
            print("global uplink failed: \(error)")
        }
    }
}
