import HTTP
import UnidocPages

extension ServerResponse
{
    var statisticalStatus:WritableKeyPath<ServerTour.Stats.ByStatus, Int>
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
