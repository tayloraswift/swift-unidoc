import Multiparts
import NIOHPACK
import URI

extension Unidoc
{
    @frozen public
    struct StreamedRequest:Sendable
    {
        public
        let authorization:Authorization
        public
        let endpoint:any ProceduralOperation

        @inlinable public
        init(authorization:Authorization, endpoint:any ProceduralOperation)
        {
            self.authorization = authorization
            self.endpoint = endpoint
        }
    }
}
extension Unidoc.StreamedRequest
{
    public
    init?(put uri:URI, headers:HPACKHeaders)
    {
        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst(),
        let root:Unidoc.ServerRoot = .init(rawValue: root)
        else
        {
            return nil
        }

        guard case .builder = root,
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

        self.init(authorization: .from(headers),
            endpoint: Unidoc.BuilderUploadOperation.init(route: route))
    }
}
