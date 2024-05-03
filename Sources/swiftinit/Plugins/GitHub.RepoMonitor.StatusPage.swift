import HTML
import GitHubAPI
import UnidocRender
import UnixTime
import URI

extension GitHub.RepoMonitor
{
    struct StatusPage:Sendable
    {
        let error:(any Error)?
        let reposCrawled:Int
        let tagsCrawled:Int
        let tagsUpdated:Int
        let events:Unidoc.EventList<Event>

        init(error:(any Error)?,
            reposCrawled:Int,
            tagsCrawled:Int,
            tagsUpdated:Int,
            events:Unidoc.EventList<Event>)
        {
            self.error = error
            self.reposCrawled = reposCrawled
            self.tagsCrawled = tagsCrawled
            self.tagsUpdated = tagsUpdated
            self.events = events
        }
    }
}
extension GitHub.RepoMonitor.StatusPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    var title:String { "GitHub repo monitor" }
}
extension GitHub.RepoMonitor.StatusPage:Unidoc.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = "GitHub repo monitor"

        if  let error:any Error = self.error
        {
            main[.p] = "Most recent error:"
            main[.pre, .code] = "\(error)"
        }

        main[.p] = "Repos crawled: \(self.reposCrawled)"
        main[.p] = "Tags crawled: \(self.tagsCrawled)"
        main[.p] = "Tags updated: \(self.tagsUpdated)"

        main[.section, { $0.class = "events" }]
        {
            $0[.h2] = "Events"
            $0[.ol] { $0.class = "events" } = self.events
        }
    }
}
