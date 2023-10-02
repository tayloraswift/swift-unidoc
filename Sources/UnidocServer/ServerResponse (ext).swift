import HTTP
import UnidocProfiling

extension ServerResponse
{
    var category:WritableKeyPath<ServerProfile.ByStatus, Int>
    {
        switch self
        {
        case .ok(let resource):
            if  case .length = resource.content
            {
                return \.notModified
            }
            else
            {
                return \.ok
            }

        case .multiple:
            return \.multipleChoices

        case .redirect(.temporary, _):
            return \.redirectedTemporarily

        case .redirect(.permanent, _):
            return \.redirectedPermanently

        case .notFound:
            return \.notFound

        case .error:
            return \.errored

        case _:
            return \.unauthorized
        }
    }
}
