import HTML
import GitHubAPI
import SwiftinitRender
import URI

extension GitHub.RepoMonitor
{
    struct StatusPage:Sendable
    {
        var error:(any Error)?
        var reposCrawled:Int
        var tagsCrawled:Int
        var tagsUpdated:Int
        var lag:Duration?

        init()
        {
            self.error = nil
            self.reposCrawled = 0
            self.tagsCrawled = 0
            self.tagsUpdated = 0
            self.lag = nil
        }
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
        main[.h1] = "GitHub repo monitor"

        if  let error:any Error = self.error
        {
            main[.p] = "Error: \(error)"
        }
        else
        {
            main[.p] = "Repos crawled: \(self.reposCrawled)"
            main[.p] = "Tags crawled: \(self.tagsCrawled)"
            main[.p] = "Tags updated: \(self.tagsUpdated)"
            main[.p] = "Lag: \(self.lag?.description ?? "unknown")"
        }
    }
}
