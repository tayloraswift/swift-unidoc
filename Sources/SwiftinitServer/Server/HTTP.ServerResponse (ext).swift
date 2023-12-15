import HTTP
import UnidocProfiling

extension HTTP.ServerResponse
{
    var category:WritableKeyPath<ServerProfile.ByStatus, Int>
    {
        switch self
        {
        case .resource(let resource, status: let status):
            if  case .length = resource.content,
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

        case .redirect(.permanent, _):
            return \.redirectedPermanently

        case .redirect(_, _):
            return \.redirectedTemporarily
        }
    }
}
