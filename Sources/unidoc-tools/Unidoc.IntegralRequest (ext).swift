import HTTPServer
import IP
import Multiparts
import NIOHPACK
import NIOHTTP1
import UnidocServer
import URI

extension Unidoc.IntegralRequest:HTTP.ServerIntegralRequest
{
    public
    init?(get uri:URI, headers:HTTPHeaders, origin:IP.Origin)
    {
        let incoming:Unidoc.IncomingRequest = .init(headers: headers, origin: origin, uri: uri)
        self.init(get: incoming)
    }

    public
    init?(get uri:URI, headers:HPACKHeaders, origin:IP.Origin)
    {
        let incoming:Unidoc.IncomingRequest = .init(headers: headers, origin: origin, uri: uri)
        self.init(get: incoming)
    }

    public
    init?(post uri:URI, headers:HPACKHeaders, origin:IP.Origin, body:borrowing [UInt8])
    {
        let incoming:Unidoc.IncomingRequest = .init(headers: headers, origin: origin, uri: uri)
        self.init(post: incoming, body: body)
    }
}
