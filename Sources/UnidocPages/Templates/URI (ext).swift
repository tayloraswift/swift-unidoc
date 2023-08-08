import UnidocSelectors
import UnidocRecords
import URI

extension URI
{
    init(article:__shared Record.Master.Article, in trunk:__shared Record.Trunk)
    {
        self = Site.Guides.uri

        self.path += trunk
        self.path += article.stem
    }
    init(culture:__shared Record.Master.Culture, in trunk:__shared Record.Trunk)
    {
        self = Site.Docs.uri

        self.path += trunk
        self.path += culture.stem
    }
    init(decl:__shared Record.Master.Decl,
        in trunk:__shared Record.Trunk,
        disambiguate:Bool = true)
    {
        self = Site.Docs.uri

        self.path += trunk
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
