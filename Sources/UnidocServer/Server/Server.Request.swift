import HTTP
import NIOCore

extension Server
{
    struct Request:Sendable
    {
        let operation:any InteractiveOperation
        let cookies:Cookies
        let promise:EventLoopPromise<ServerResponse>

        init(
            operation:any InteractiveOperation,
            cookies:Cookies,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.operation = operation
            self.cookies = cookies
            self.promise = promise
        }
    }
}
