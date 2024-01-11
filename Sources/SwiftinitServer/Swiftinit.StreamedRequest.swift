import HTTPServer
import IP
import Media
import Multiparts
import NIOHPACK
import SwiftinitPages
import URI

extension Swiftinit
{
    struct StreamedRequest:Sendable
    {
        let endpoint:Swiftinit.AnyEndpoint
        let cookies:Swiftinit.Cookies

        init(endpoint:Swiftinit.AnyEndpoint, cookies:Swiftinit.Cookies)
        {
            self.endpoint = endpoint
            self.cookies = cookies
        }
    }
}
extension Swiftinit.StreamedRequest:HTTP.ServerStreamedRequest
{
    init?(put path:String, headers:HPACKHeaders)
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

        let cookies:Swiftinit.Cookies = .init(header: headers["cookie"])

        let endpoint:Swiftinit.AnyEndpoint?

        switch root
        {
        case Swiftinit.Root.api.id:
            endpoint = try? .put(api: trunk, type: type)

        case _:
            return nil
        }

        if  let endpoint:Swiftinit.AnyEndpoint
        {
            self.init(endpoint: endpoint, cookies: cookies)
        }
        else
        {
            return nil
        }
    }
}
