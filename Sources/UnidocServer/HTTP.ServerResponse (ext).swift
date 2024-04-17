import HTTP
import UnidocProfiling

extension HTTP.ServerResponse
{
    var category:WritableKeyPath<ServerProfile.ByStatus, Int>
    {
        switch self
        {
        case .resource(let resource, status: let status):
            if  case nil = resource.content,
                case 200 = status
            {
                return \.notModified
            }

            switch status
            {
            case 200:   return \.ok
            case 300:   return \.multipleChoices
            case 404:   return \.notFound
            case 410:   return \.gone
            case 500:   return \.errored
            default:    return \.unauthorized
            }

        case .redirect(let redirect, _):
            switch redirect.status
            {
            case 303:   return \.redirectedTemporarily
            case 307:   return \.redirectedTemporarily
            case 308:   return \.redirectedPermanently
            default:    return \.redirectedTemporarily
            }
        }
    }
}
