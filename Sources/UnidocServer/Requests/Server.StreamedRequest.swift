import HTTPServer
import IP
import Media
import Multiparts
import NIOHPACK
import UnidocAutomation
import UnidocPages
import URI

extension Server
{
    struct StreamedRequest:Sendable
    {
        let endpoint:Endpoint
        let cookies:Cookies

        init(endpoint:Endpoint, cookies:Cookies)
        {
            self.endpoint = endpoint
            self.cookies = cookies
        }
    }
}
extension Server.StreamedRequest:HTTPServerStreamedRequest
{
    init?(put path:String,
        headers:HPACKHeaders,
        address _:IP.V6)
    {
        guard let uri:URI = .init(path)
        else
        {
            return nil
        }

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst(),
        let trunk:String = path.popFirst(),
        let type:String = headers["content-type"].first,
        let type:ContentType = .init(type)
        else
        {
            return nil
        }

        let cookies:Server.Cookies = .init(headers["cookie"])

        let endpoint:Server.Endpoint?

        switch root
        {
        case UnidocAPI.root:
            endpoint = try? .put(api: trunk, type: type)

        case _:
            return nil
        }

        if  let endpoint:Server.Endpoint
        {
            self.init(endpoint: endpoint, cookies: cookies)
        }
        else
        {
            return nil
        }
    }
}
