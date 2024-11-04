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
        let origin:Origin
        public
        let uri:URI

        init(origin:Origin, uri:URI)
        {
            self.origin = origin
            self.uri = uri
        }
    }
}
