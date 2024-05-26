import HTTP

extension Unidoc
{
    public
    protocol ProceduralOperation:Sendable
    {
        func perform(on server:borrowing ServerLoop,
            payload:consuming [UInt8],
            request:ServerLoop.Promise) async
    }
}
