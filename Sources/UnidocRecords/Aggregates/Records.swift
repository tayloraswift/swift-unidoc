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
    var extensions:[Record.Extension]

    public
    var articles:[Record.Master.Article]
    public
    var cultures:[Record.Master.Culture]
    public
    var decls:[Record.Master.Decl]
    public
    var files:[Record.Master.File]

    @inlinable public
    init(zone:Record.Zone,
        extensions:[Record.Extension] = [],
        articles:[Record.Master.Article] = [],
        cultures:[Record.Master.Culture] = [],
        decls:[Record.Master.Decl] = [],
        files:[Record.Master.File] = [])
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

        self.extensions = extensions
        self.articles = articles
        self.cultures = cultures
        self.decls = decls
        self.files = files
    }
}
extension Records
{
    @inlinable public
    var masters:Masters
    {
        .init(
            articles: self.articles,
            cultures: self.cultures,
            decls: self.decls,
            files: self.files)
    }

    @inlinable public
    func extensions(latest:Bool) -> Extensions<Bool>
    {
        .init(self.extensions, latest: latest)
    }
}
