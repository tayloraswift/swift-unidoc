import HTML
import GitHubAPI
import SwiftinitRender
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
        let entries:[Unidoc.EventBuffer<any Swiftinit.ServerPluginEvent>.Entry]

        private
        init(error:(any Error)?,
            reposCrawled:Int,
            tagsCrawled:Int,
            tagsUpdated:Int,
            entries:[Unidoc.EventBuffer<any Swiftinit.ServerPluginEvent>.Entry])
        {
            self.error = error
            self.reposCrawled = reposCrawled
            self.tagsCrawled = tagsCrawled
            self.tagsUpdated = tagsUpdated
            self.entries = entries
        }
    }
}
extension GitHub.RepoMonitor.StatusPage
{
    init(error:(any Error)?,
        reposCrawled:Int,
        tagsCrawled:Int,
        tagsUpdated:Int,
        buffer:borrowing Unidoc.EventBuffer<any Swiftinit.ServerPluginEvent>)
    {
        self.init(error: error,
            reposCrawled: reposCrawled,
            tagsCrawled: tagsCrawled,
            tagsUpdated: tagsUpdated,
            entries: [_].init(buffer.entries))
    }
}
extension GitHub.RepoMonitor.StatusPage:Swiftinit.RenderablePage, Swiftinit.DynamicPage
{
    var title:String { "GitHub repo monitor" }
}
extension GitHub.RepoMonitor.StatusPage:Swiftinit.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        let now:UnixInstant = .now()

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
            $0[.ol, { $0.class = "events" }]
            {
                for entry:Unidoc.EventBuffer<any Swiftinit.ServerPluginEvent>.Entry
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
