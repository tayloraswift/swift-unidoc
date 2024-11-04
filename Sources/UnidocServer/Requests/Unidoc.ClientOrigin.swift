import HTTPServer
import IP

extension Unidoc
{
    @frozen public
    struct ClientOrigin:Sendable
    {
        public
        let origin:HTTP.ServerRequest.Origin
        public
        let guess:Unidoc.ClientGuess?

        @inlinable public
        init(origin:HTTP.ServerRequest.Origin, guess:Unidoc.ClientGuess? = nil)
        {
            self.origin = origin
            self.guess = guess
        }
    }
}
