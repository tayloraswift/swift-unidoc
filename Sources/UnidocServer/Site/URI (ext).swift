import UnidocRecords
import URI
import URI

extension URI
{
    init(article:__shared Record.Master.Article, in zone:__shared Record.Zone.Names)
    {
        self = Site.Learn.uri

        self.path += zone
        self.path += article.stem
    }
    init(culture:__shared Record.Master.Culture, in zone:__shared Record.Zone.Names)
    {
        self = Site.Docs.uri

        self.path += zone
        self.path += culture.stem
    }
    init(decl:__shared Record.Master.Decl,
        in zone:__shared Record.Zone.Names,
        disambiguate:Bool = true)
    {
        self = Site.Docs.uri

        self.path += zone
        self.path += decl.stem

        guard disambiguate
        else
        {
            return
        }

        switch decl.route
        {
        case .hashed:   self["hash"] = "\(decl.hash)"
        case .unhashed: break
        }
    }
}
