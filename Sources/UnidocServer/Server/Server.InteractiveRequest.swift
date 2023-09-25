import HTTP
import NIOCore

extension Server
{
    struct InteractiveRequest:Sendable
    {
        let operation:any InteractiveEndpoint
        let cookies:Cookies
        let promise:EventLoopPromise<ServerResponse>

        init(
            operation:any InteractiveEndpoint,
            cookies:Cookies,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.operation = operation
            self.cookies = cookies
            self.promise = promise
        }
    }
}
