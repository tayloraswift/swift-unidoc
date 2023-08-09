import UnidocRecords
import URI

enum URL
{
    case relative(URI)
    case absolute(String)
}
extension URL:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .relative(let uri): return "\(uri)"
        case .absolute(let url): return    url
        }
    }
}

extension URL
{
    init?(master:__shared Record.Master,
        in zone:__shared Record.Zone,
        disambiguate:Bool = true)
    {
        switch master
        {
        case .article(let article): self = .relative(.init(article: article, in: zone))
        case .culture(let culture): self = .relative(.init(culture: culture, in: zone))
        case .decl(let decl):       self = .relative(.init(decl: decl, in: zone))
        case .file(let file):
            if  let url:String = zone.url(github: file.symbol)
            {
                self = .absolute(url)
            }
            else
            {
                return nil
            }
        }
    }
}
