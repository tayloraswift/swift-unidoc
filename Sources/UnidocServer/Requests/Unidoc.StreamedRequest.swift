import Multiparts
import HTTP
import URI

extension Unidoc
{
    struct StreamedRequest:Sendable
    {
        let endpoint:any ProceduralOperation

        private
        init(endpoint:any ProceduralOperation)
        {
            self.endpoint = endpoint
        }
    }
}
extension Unidoc.StreamedRequest
{
    init?(from request:__shared HTTP.ServerRequest)
    {
        var path:ArraySlice<String> = request.uri.path.normalized(lowercase: true)[...]

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
        case .media(.application(.bson, charset: nil))? = request.headers.contentType
        else
        {
            return nil
        }

        self.init(endpoint: Unidoc.BuilderUploadOperation.init(route: route))
    }
}
