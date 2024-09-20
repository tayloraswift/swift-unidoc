import HTTPServer
import IP

extension Unidoc
{
    @frozen public
    struct ClientOrigin:Sendable
    {
        public
        let ip:HTTP.ServerRequest.Origin
        public
        let guess:Unidoc.ClientGuess?

        @inlinable public
        init(ip:HTTP.ServerRequest.Origin, guess:Unidoc.ClientGuess? = nil)
        {
            self.ip = ip
            self.guess = guess
        }
    }
}
