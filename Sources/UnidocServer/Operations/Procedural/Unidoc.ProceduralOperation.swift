import HTTP

extension Unidoc
{
    public
    protocol ProceduralOperation:Sendable
    {
        func serve(request:Server.Promise, with payload:[UInt8], from server:Server) async
    }
}
