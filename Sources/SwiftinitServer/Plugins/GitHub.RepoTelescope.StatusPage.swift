import HTML
import GitHubAPI
import SwiftinitRender
import URI

extension GitHub.RepoTelescope
{
    struct StatusPage:Sendable
    {
        var error:(any Error)?
        var windowsCrawled:Int
        var reposCrawled:Int
        var reposIndexed:Int

        init()
        {
            self.error = nil
            self.windowsCrawled = 0
            self.reposCrawled = 0
            self.reposIndexed = 0
        }
    }
}
extension GitHub.RepoTelescope.StatusPage:Swiftinit.RenderablePage, Swiftinit.DynamicPage
{
    var title:String { "GitHub repo telescope" }
}
extension GitHub.RepoTelescope.StatusPage:Swiftinit.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.h1] = "GitHub repo telescope"

        if  let error:any Error = self.error
        {
            main[.p] = "Error: \(error)"
        }
        else
        {
            main[.p] = "Windows crawled: \(self.windowsCrawled)"
            main[.p] = "Repos crawled: \(self.reposCrawled)"
            main[.p] = "Repos indexed: \(self.reposIndexed)"
        }
    }
}
