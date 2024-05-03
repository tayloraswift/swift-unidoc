import HTML
import GitHubAPI
import UnidocRender
import UnixTime
import URI

extension GitHub.RepoTelescope
{
    struct StatusPage:Sendable
    {
        let error:(any Error)?
        let windowsCrawled:Int
        let reposCrawled:Int
        let reposIndexed:Int
        let events:Unidoc.EventList<Event>

        init(error:(any Error)?,
            windowsCrawled:Int,
            reposCrawled:Int,
            reposIndexed:Int,
            events:Unidoc.EventList<Event>)
        {
            self.error = error
            self.windowsCrawled = windowsCrawled
            self.reposCrawled = reposCrawled
            self.reposIndexed = reposIndexed
            self.events = events
        }
    }
}
extension GitHub.RepoTelescope.StatusPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    var title:String { "GitHub repo telescope" }
}
extension GitHub.RepoTelescope.StatusPage:Unidoc.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = "GitHub repo telescope"

        if  let error:any Error = self.error
        {
            main[.p] = "Most recent error:"
            main[.pre, .code] = "\(error)"
        }

        main[.p] = "Windows crawled: \(self.windowsCrawled)"
        main[.p] = "Repos crawled: \(self.reposCrawled)"
        main[.p] = "Repos indexed: \(self.reposIndexed)"

        main[.section, { $0.class = "events" }]
        {
            $0[.h2] = "Events"
            $0[.ol] { $0.class = "events" } = self.events
        }
    }
}
