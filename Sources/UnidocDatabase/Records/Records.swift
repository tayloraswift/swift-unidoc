@frozen public
struct Records:Sendable
{
    public
    let zone:Record.Zone

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

        self.articles = articles
        self.cultures = cultures
        self.decls = decls
        self.extensions = extensions
    }
}
