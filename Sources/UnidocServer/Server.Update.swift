import HTTP

extension Server
{
    struct Update:Sendable
    {
        let endpoint:any ProceduralEndpoint
        let payload:[UInt8]
        let promise:CheckedContinuation<ServerResponse, any Error>

        init(endpoint:any ProceduralEndpoint,
            payload:[UInt8] = [],
            promise:CheckedContinuation<ServerResponse, any Error>)
        {
            self.endpoint = endpoint
            self.payload = payload
            self.promise = promise
        }
    }
}
