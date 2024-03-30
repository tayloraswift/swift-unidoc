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
        case Swiftinit.Root.ssgc.id? = path.popFirst(),
        let outcome:String = path.popFirst(),
        let outcome:Unidoc.BuildOutcome = .init(outcome)
        else
        {
            return nil
        }

        //  Validate content type.
        guard
        let type:String = headers["content-type"].first,
        let type:ContentType = .init(type),
        case .media(.application(.bson, charset: nil)) = type
        else
        {
            return nil
        }

        self.init(
            endpoint: Swiftinit.BuilderUploadEndpoint.init(outcome: outcome),
            cookies: .init(header: headers["cookie"]))
    }
}
