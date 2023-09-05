import HTTPServer
import NIOCore

extension Server
{
    struct Request:Sendable
    {
        let operation:any StatefulOperation
        let cookies:Cookies
        let promise:EventLoopPromise<ServerResponse>

        init(
            operation:any StatefulOperation,
            cookies:Cookies,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.operation = operation
            self.cookies = cookies
            self.promise = promise
        }
    }
}
