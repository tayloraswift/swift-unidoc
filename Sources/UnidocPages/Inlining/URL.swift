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
        case .article(let article): self = .relative(Site.Docs[zone, article.shoot])
        case .culture(let culture): self = .relative(Site.Docs[zone, culture.shoot])
        case .decl(let decl):       self = .relative(Site.Docs[zone, decl.shoot])
        case .file(let file):
            if  let url:String = zone.github(blob: file.symbol)
            {
                self = .absolute(url)
            }
            else
            {
                return nil
            }
        case .meta:                 self = .relative(Site.Docs[zone])
        }
    }
}
