import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    enum UserSession:Equatable, Hashable, Sendable
    {
        case web(Web)
        case api(API)
    }
}

@available(*, deprecated)
extension Unidoc.UserSession:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .web(let web): return web.description
        case .api(let api): return api.description
        }
    }
}
