import HTTP

extension Swiftinit.ServerLoop
{
    struct Update:Sendable
    {
        let endpoint:any Swiftinit.ProceduralEndpoint
        let payload:[UInt8]
        let promise:Promise

        init(endpoint:any Swiftinit.ProceduralEndpoint,
            payload:[UInt8] = [],
            promise:Promise)
        {
            self.endpoint = endpoint
            self.payload = payload
            self.promise = promise
        }
    }
}
