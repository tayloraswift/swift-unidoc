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
        var address:IP.V6
        public
        var service:IP.Service?
        public
        var path:String

        @inlinable public
        init(
            version:HTTP,
            headers:HTTP.ProfileHeaders,
            address:IP.V6,
            service:IP.Service?,
            path:String)
        {
            self.version = version
            self.headers = headers
            self.address = address
            self.service = service
            self.path = path
        }
    }
}
