import HTTP

extension Unidoc
{
    public
    protocol ProceduralOperation:Sendable
    {
        func perform(on server:Server,
            payload:consuming [UInt8],
            request:Server.Promise) async
    }
}
