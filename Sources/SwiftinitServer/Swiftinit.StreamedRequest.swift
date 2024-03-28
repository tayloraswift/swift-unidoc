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
        let endpoint:any ProceduralEndpoint
        let cookies:Swiftinit.Cookies

        init(endpoint:any ProceduralEndpoint, cookies:Swiftinit.Cookies)
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
        case Swiftinit.Root.api.id? = path.popFirst(),
        let trunk:String = path.popFirst(),
        let trunk:Swiftinit.API.Put = .init(trunk),
        let type:String = headers["content-type"].first,
        let type:ContentType = .init(type)
        else
        {
            return nil
        }

        let cookies:Swiftinit.Cookies = .init(header: headers["cookie"])

        let endpoint:any Swiftinit.ProceduralEndpoint
        switch (trunk, type)
        {
        case (.snapshot, .media(.application(.bson, charset: nil))):
            endpoint = Swiftinit.GraphStorageEndpoint.placed

        case (.graph, .media(.application(.bson, charset: nil))):
            endpoint = Swiftinit.GraphStorageEndpoint.object

        case (_, _):
            return nil
        }

        self.init(endpoint: endpoint, cookies: cookies)
    }
}
