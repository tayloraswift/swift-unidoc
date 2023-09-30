import HTTP
import NIOCore

extension Server
{
    struct Request<Endpoint>:Sendable where Endpoint:Sendable
    {
        let endpoint:Endpoint

        let cookies:Cookies
        let agent:Agent?
        let uri:String?

        let promise:EventLoopPromise<ServerResponse>

        init(endpoint:Endpoint,
            cookies:Cookies,
            agent:Agent? = nil,
            uri:String? = nil,
            promise:EventLoopPromise<ServerResponse>)
        {
            self.endpoint = endpoint
            self.cookies = cookies
            self.agent = agent
            self.uri = uri
            self.promise = promise
        }
    }
}
