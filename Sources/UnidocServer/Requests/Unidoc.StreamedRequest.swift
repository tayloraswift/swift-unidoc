import Multiparts
import NIOHPACK
import URI

extension Unidoc
{
    @frozen public
    struct StreamedRequest:Sendable
    {
        public
        let endpoint:any ProceduralOperation
        public
        let cookies:Cookies

        @inlinable public
        init(endpoint:any ProceduralOperation, cookies:Cookies)
        {
            self.endpoint = endpoint
            self.cookies = cookies
        }
    }
}
extension Unidoc.StreamedRequest
{
    public
    init?(put path:String, headers:HPACKHeaders)
    {
        guard let uri:URI = .init(path)
        else
        {
            return nil
        }

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        case Unidoc.ServerRoot.ssgc.id? = path.popFirst(),
        let route:String = path.popFirst(),
        let route:Unidoc.BuildRoute = .init(route)
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
            endpoint: Unidoc.BuilderUploadOperation.init(route: route),
            cookies: .init(header: headers["cookie"]))
    }
}
