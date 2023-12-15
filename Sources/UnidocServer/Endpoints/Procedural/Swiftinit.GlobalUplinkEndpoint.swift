import MongoDB

extension Swiftinit
{
    struct GlobalUplinkEndpoint:Sendable
    {
        init()
        {
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
        try? await server.db.unidoc.rebuild(with: session)
    }
}