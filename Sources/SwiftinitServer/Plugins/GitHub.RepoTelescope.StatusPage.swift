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
        let entries:[Unidoc.EventBuffer<any Unidoc.ServerPluginEvent>.Entry]

        private
        init(error:(any Error)?,
            windowsCrawled:Int,
            reposCrawled:Int,
            reposIndexed:Int,
            entries:[Unidoc.EventBuffer<any Unidoc.ServerPluginEvent>.Entry])
        {
            self.error = error
            self.windowsCrawled = windowsCrawled
            self.reposCrawled = reposCrawled
            self.reposIndexed = reposIndexed
            self.entries = entries
        }
    }
}
extension GitHub.RepoTelescope.StatusPage
{
    init(error:(any Error)?,
        windowsCrawled:Int,
        reposCrawled:Int,
        reposIndexed:Int,
        buffer:borrowing Unidoc.EventBuffer<any Unidoc.ServerPluginEvent>)
    {
        self.init(error: error,
            windowsCrawled: windowsCrawled,
            reposCrawled: reposCrawled,
            reposIndexed: reposIndexed,
            entries: [_].init(buffer.entries))
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
        let now:UnixInstant = .now()

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
            $0[.ol, { $0.class = "events" }]
            {
                for entry:Unidoc.EventBuffer<any Unidoc.ServerPluginEvent>.Entry
                    in self.entries.reversed()
                {
                    $0[.li]
                    {
                        $0[.h3] = type(of: entry.event).name
                        $0[.p] = entry.time(now: now)

                        $0[.dl] { $0 *= entry.event }
                    }
                }
            }
        }
    }
}
