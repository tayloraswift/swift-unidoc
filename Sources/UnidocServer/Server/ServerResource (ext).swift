import HTTP
import UnidocPages

extension ServerResource
{
    var statisticalStatus:WritableKeyPath<ServerTour.Stats.ByStatus, Int>
    {
        switch (self.results, self.content)
        {
        case (.error, _):       return \.errored
        case (.forbidden, _):   return \.unauthorized
        case (.none, _):        return \.notFound
        case (_, .length):      return \.notModified
        case (.many, _):        return \.ok
        case (.one, _):         return \.ok
        }
    }
}
