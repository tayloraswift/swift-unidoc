import HTTP
import NIOCore

extension Server
{
    struct Request<Endpoint>:Sendable where Endpoint:Sendable
    {
        let endpoint:Endpoint

        let cookies:Cookies
        let agent:String?

        let promise:EventLoopPromise<ServerResponse>

        init(endpoint:Endpoint,
            cookies:Cookies,
            agent:String? = nil,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.endpoint = endpoint
            self.cookies = cookies
            self.agent = agent
            self.promise = promise
        }
    }
}
