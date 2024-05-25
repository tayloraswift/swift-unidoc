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
        let metadata:Metadata = .init(headers: headers, origin: origin, uri: uri)
        self.init(get: metadata)
    }

    public
    init?(get uri:URI, headers:HPACKHeaders, origin:IP.Origin)
    {
        let metadata:Metadata = .init(headers: headers, origin: origin, uri: uri)
        self.init(get: metadata)
    }

    public
    init?(post uri:URI, headers:HPACKHeaders, origin:IP.Origin, body:borrowing [UInt8])
    {
        let metadata:Metadata = .init(headers: headers, origin: origin, uri: uri)
        self.init(post: metadata, body: body)
    }
}
