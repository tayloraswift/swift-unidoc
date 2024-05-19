import HTTPServer
import IP

extension ServerTour
{
    @frozen public
    struct Request:Equatable, Sendable
    {
        public
        var version:HTTP
        public
        var headers:HTTP.ProfileHeaders
        public
        var origin:IP.Origin
        public
        var path:String

        @inlinable public
        init(
            version:HTTP,
            headers:HTTP.ProfileHeaders,
            origin:IP.Origin,
            path:String)
        {
            self.version = version
            self.headers = headers
            self.origin = origin
            self.path = path
        }
    }
}
