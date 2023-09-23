import HTTP
import UnidocPages

extension ServerResponse
{
    var statisticalStatus:WritableKeyPath<ServerTour.Stats.ByStatus, Int>
    {
        switch self
        {
        case .error:
            return \.errored

        case .forbidden:
            return \.unauthorized

        case .multiple:
            return \.multipleChoices

        case .notFound:
            return \.notFound

        case .ok(let resource):
            if  case .length = resource.content
            {
                return \.notModified
            }
            else
            {
                return \.ok
            }

        case .redirect(.temporary, _):
            return \.redirectedTemporarily

        case .redirect(.permanent, _):
            return \.redirectedPermanently
        }
    }
}
