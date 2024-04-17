import HTTPServer
import IP
import MD5
import Media
import Multiparts
import NIOHPACK
import NIOHTTP1
import UnidocServer

extension Unidoc.IntegralRequest:HTTP.ServerIntegralRequest
{
    public
    init?(get path:String,
        headers:borrowing HTTPHeaders,
        address:IP.V6,
        service:IP.Service?)
    {
        let metadata:Metadata = .init(
            headers: headers,
            address: address,
            service: service,
            path: path)

        //  Only search engines are allowed to use HTTP/1.1. Bingbot never uses
        //  HTTP/1.1, but we allow it anyway.
        switch metadata.annotation
        {
        //  There is no legitimate reason for a doll, even a barbie, to use HTTP/1.1.
        //  Such a doll is almost certainly a malicious bot that somehow passed the
        //  barbie filter.
        case .barbie(_):            return nil
        case .bratz:                return nil
        case .robot(.ahrefsbot):    return nil
        //  Crawls way too fast.
        case .robot(.amazonbot):    return nil
        case .robot(.baiduspider):  break
        case .robot(.bingbot):      break
        case .robot(.bytespider):   return nil
        case .robot(.cloudfront):   break
        case .robot(.discoursebot): break
        case .robot(.duckduckbot):  break
        case .robot(.google):       break
        case .robot(.googlebot):    break
        case .robot(.quant):        break
        case .robot(.naver):        break
        case .robot(.petal):        break
        case .robot(.seznam):       break
        case .robot(.yandexbot):    break
        case .robot(.unknown):      break
        case .robot(.other):        return nil
        case .robot(.tool):         return nil
        }

        self.init(get: metadata, tag: .init(header: headers["if-none-match"]))
    }

    public
    init?(get path:String,
        headers:borrowing HPACKHeaders,
        address:IP.V6,
        service:IP.Service?)
    {
        let metadata:Metadata = .init(
            headers: headers,
            address: address,
            service: service,
            path: path)

        firewall:
        if  path != "/robots.txt"
        {
            switch service
            {
            case .googlebot?:   break firewall
            case .bingbot?:     break firewall
            case .unknown?:     break firewall
            default:            break
            }

            guard case _? = metadata.headers.userAgent
            else
            {
                return nil
            }

            switch metadata.annotation
            {
            case .robot(.bytespider):   return nil
            default:                    break
            }
        }

        self.init(get: metadata, tag: .init(header: headers["if-none-match"]))
    }

    public
    init?(post path:String,
        headers:borrowing HPACKHeaders,
        address:IP.V6,
        service:IP.Service?,
        body:consuming [UInt8])
    {
        let metadata:Metadata = .init(
            headers: headers,
            address: address,
            service: service,
            path: path)

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
