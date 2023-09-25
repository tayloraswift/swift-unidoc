import HTTP
import NIOCore

extension Server
{
    struct Request<Endpoint>:Sendable where Endpoint:Sendable
    {
        let endpoint:Endpoint
        let cookies:Cookies
        let promise:EventLoopPromise<ServerResponse>

        init(endpoint:Endpoint,
            cookies:Cookies,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.endpoint = endpoint
            self.cookies = cookies
            self.promise = promise
        }
    }
}
