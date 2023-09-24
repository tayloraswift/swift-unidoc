import HTTP
import NIOCore

extension Server
{
    struct ProceduralRequest:Sendable
    {
        let operation:any ProceduralEndpoint
        let promise:EventLoopPromise<ServerResponse>

        init(
            operation:any ProceduralEndpoint,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.operation = operation
            self.promise = promise
        }
    }
}
