import IP
import URI

extension HTTP
{
    /// A ``ServerRequest`` contains all the metadata about an incoming request, except for
    /// the headers. This is because the headers have a different format depending on the HTTP
    /// protocol version, and eagarly converting them to a common format would be wasteful.
    @frozen public
    struct ServerRequest:Sendable
    {
        public
        let uri:URI
        public
        let ip:Origin

        init(uri:URI, ip:Origin)
        {
            self.uri = uri
            self.ip = ip
        }
    }
}
