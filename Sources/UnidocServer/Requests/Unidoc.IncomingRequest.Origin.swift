import HTTPServer
import IP

extension Unidoc.IncomingRequest
{
    @frozen public
    struct Origin:Sendable
    {
        public
        let ip:IP.Origin
        public
        let guess:Unidoc.ClientGuess?

        private
        init(ip:IP.Origin, guess:Unidoc.ClientGuess?)
        {
            self.ip = ip
            self.guess = guess
        }
    }
}
extension Unidoc.IncomingRequest.Origin
{
    /// Sets the request origin if the IP’s ``IP.Origin/owner`` is anything but
    /// ``IP.Owner/unknown`` or ``IP.Owner/known``.
    init?(ip:IP.Origin)
    {
        switch ip.owner
        {
        case .unknown:  return nil
        case .known:    return nil
        case _:         self.init(ip: ip, guess: nil)
        }
    }

    init(ip:IP.Origin, client:Unidoc.ClientGuess)
    {
        self.init(ip: ip, guess: client)
    }
}
