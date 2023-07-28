import HTML
import UnidocRecords
import UnidocDatabase
import URI

extension Site.Docs
{
    enum DeepPage
    {
        case article(Article)
        case culture(Culture)
        case decl(Decl)
        case disambiguation(Site.DisambiguationPage)
    }
}
extension Site.Docs.DeepPage
{
    var location:URI
    {
        switch self
        {
        case .article       (let page): return page.location
        case .culture       (let page): return page.location
        case .decl          (let page): return page.location
        case .disambiguation(let page): return page.location
        }
    }

    private
    var title:String?
    {
        switch self
        {
        case .article   (let page): return page.title
        case .culture   (let page): return page.title
        case .decl      (let page): return page.title
        case .disambiguation:       return "Disambiguation Page"
        }
    }
}
extension Site.Docs.DeepPage
{
    init?(_ output:[DeepQuery.Output])
    {
        if output.count == 1
        {
            self.init(output[0])
        }
        else
        {
            return nil
        }
    }

    private
    init?(_ output:DeepQuery.Output)
    {
        guard output.principal.count == 1
        else
        {
            return nil
        }

        let principal:DeepQuery.Output.Principal = output.principal[0]

        if  let master:Record.Master = principal.master
        {
            let inliner:Inliner = .init(principal: master.id, zone: principal.zone)
            inliner.masters.add(output.secondary)
            inliner.zones.add(output.zones)

            switch master
            {
            case .article(let master):
                self = .article(.init(inliner, master: master, groups: principal.groups))

            case .culture(let master):
                self = .culture(.init(inliner, master: master, groups: principal.groups))

            case .decl(let master):
                self = .decl(.init(inliner, master: master, groups: principal.groups))

            case .file:
                //  We should never get this as principal output!
                return nil
            }
        }
        else if let first:Record.Master = principal.matches.first
        {
            let inliner:Inliner = .init(principal: first.id.zone, zone: principal.zone)

            var identity:URI.Path = []

            if  let stem:Record.Stem = first.stem
            {
                identity += stem
            }

            let location:URI

            switch first
            {
            case .article(let first):   location = .init(article: first, in: principal.zone)
            case .culture(let first):   location = .init(culture: first, in: principal.zone)
            case .decl(let first):      location = .init(decl: first, in: principal.zone,
                disambiguate: false)
            //  We should never get this as principal output!
            case .file:                 return nil
            }

            self = .disambiguation(.init(principal.matches,
                identity: identity,
                location: location,
                inliner: inliner))
        }
        else
        {
            return nil
        }
    }
}
extension Site.Docs.DeepPage:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.head]
        {
            $0[.title] = self.title
            $0[.meta] { $0.charset = "UTF-8" }
            $0[.meta]
            {
                $0.name     = "viewport"
                $0.content  = "width=device-width, initial-scale=1"
            }
            $0[.link] { $0.href = "\(Site.Assets[.fonts_css])" ; $0.rel = .stylesheet }
            $0[.link] { $0.href = "\(Site.Assets[.main_css])" ; $0.rel = .stylesheet }
        }

        html[.body]
        {
            switch self
            {
            case .article       (let content):
                $0[.main] = content

            case .culture       (let content):
                $0[.main] = content

            case .decl          (let content):
                $0[.header] { $0[.nav] { $0.class = "decl" } = content.breadcrumbs }
                $0[.main] = content

            case .disambiguation(let content):
                $0[.main] = content
            }
        }
    }
}
