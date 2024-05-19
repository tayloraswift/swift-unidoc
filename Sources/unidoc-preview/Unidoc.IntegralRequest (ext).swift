import HTTPServer
import IP
import Multiparts
import NIOHPACK
import NIOHTTP1
import UnidocServer

extension Unidoc.IntegralRequest:HTTP.ServerIntegralRequest
{
    public
    init?(get path:String,
        headers:borrowing HTTPHeaders,
        origin:IP.Origin)
    {
        self.init(get: .init(headers: headers, origin: origin, path: path), tag: nil)
    }

    public
    init?(get path:String,
        headers:borrowing HPACKHeaders,
        origin:IP.Origin)
    {
        self.init(get: .init(headers: headers, origin: origin, path: path), tag: nil)
    }

    public
    init?(post path:String,
        headers:borrowing HPACKHeaders,
        origin:IP.Origin,
        body:consuming [UInt8])
    {
        let metadata:Metadata = .init(headers: headers, origin: origin, path: path)

        guard
        let type:String = headers["content-type"].first,
        let type:ContentType = .init(type)
        else
        {
            return nil
        }

        self.init(post: metadata, body: body, type: type)
    }
}
