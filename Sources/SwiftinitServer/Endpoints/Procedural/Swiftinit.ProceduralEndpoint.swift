import HTTP

extension Swiftinit
{
    protocol ProceduralEndpoint:Sendable
    {
        func perform(on server:borrowing Server,
            payload:consuming [UInt8],
            request:ServerLoop.Promise) async
    }
}
