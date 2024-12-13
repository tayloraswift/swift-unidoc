import IP
import URI

extension HTTP
{
    /// A ``ServerRequest`` contains all the metadata about an incoming request.
    @frozen public
    struct ServerRequest:Sendable
    {
        public
        let headers:Headers
        public
        let origin:Origin
        public
        let uri:URI

        init(headers:Headers, origin:Origin, uri:URI)
        {
            self.headers = headers
            self.origin = origin
            self.uri = uri
        }
    }
}
