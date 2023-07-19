import BSONEncoding
import Unidoc

@frozen public
struct Records:Sendable
{
    public
    var latest:Unidoc.Zone?
    public
    var zone:Record.Zone

    public
    var articles:[Record.Master.Article]
    public
    var cultures:[Record.Master.Culture]
    public
    var decls:[Record.Master.Decl]
    public
    var extensions:[Record.Extension]

    @inlinable public
    init(zone:Record.Zone,
        articles:[Record.Master.Article] = [],
        cultures:[Record.Master.Culture] = [],
        decls:[Record.Master.Decl] = [],
        extensions:[Record.Extension] = [])
    {
        self.zone = zone

        if  case _? = self.zone.patch
        {
            self.latest = self.zone.id
        }
        else
        {
            self.latest = nil
        }

        self.articles = articles
        self.cultures = cultures
        self.decls = decls
        self.extensions = extensions
    }
}
extension Records
{
    @inlinable public
    var masters:Masters
    {
        .init(articles: self.articles, cultures: self.cultures, decls: self.decls)
    }

    @inlinable public
    func extensions(latest:Bool) -> Extensions<Bool>
    {
        .init(self.extensions, latest: latest)
    }
}
