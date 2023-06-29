@frozen public
struct Records:Sendable
{
    public
    var articles:[Record.Master.Article]
    public
    var modules:[Record.Master.Module]
    public
    var decls:[Record.Master.Decl]
    public
    var extensions:[Record.Extension]

    @inlinable public
    init(articles:[Record.Master.Article] = [],
        modules:[Record.Master.Module] = [],
        decls:[Record.Master.Decl] = [],
        extensions:[Record.Extension] = [])
    {
        self.articles = articles
        self.modules = modules
        self.decls = decls
        self.extensions = extensions
    }
}
