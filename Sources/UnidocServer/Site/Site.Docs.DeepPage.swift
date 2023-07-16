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
            let renderer:Renderer = .init(principal: master.id, zone: principal.zone)
            renderer.masters.add(output.secondary)
            renderer.zones.add(output.zones)

            switch master
            {
            case .article(let master):
                self = .article(.init(master,
                    extensions: principal.extensions,
                    renderer: renderer))

            case .culture(let master):
                self = .culture(.init(master,
                    extensions: principal.extensions,
                    renderer: renderer))

            case .decl(let master):
                self = .decl(.init(master,
                    extensions: principal.extensions,
                    renderer: renderer))
            }
        }
        else if let first:Record.Master = principal.matches.first
        {
            let renderer:Renderer = .init(principal: first.id.zone, zone: principal.zone)
            let location:URI = .init(master: first, in: principal.zone, disambiguate: false)

            var identity:URI.Path = []
                identity += first.stem

            self = .disambiguation(.init(principal.matches,
                identity: identity,
                location: location,
                renderer: renderer))
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
        switch self
        {
        case .article       (let content):  html += content
        case .culture       (let content):  html += content
        case .decl          (let content):  html += content
        case .disambiguation(let content):  html += content
        }
    }
}
