import Durations
import GitHubAPI
import HTML
import Symbols

extension GitHub.RepoMonitor
{
    struct CrawlingEvent
    {
        let package:Symbol.Package

        let sinceExpected:Milliseconds
        let sinceActual:Milliseconds?
        let repo:GitHub.Repo?

        init(package:Symbol.Package,
            sinceExpected:Milliseconds,
            sinceActual:Milliseconds?,
            repo:GitHub.Repo?)
        {
            self.package = package
            self.sinceExpected = sinceExpected
            self.sinceActual = sinceActual
            self.repo = repo
        }
    }
}
extension GitHub.RepoMonitor.CrawlingEvent:Swiftinit.ServerPluginEvent
{
    static
    var name:String { "Repo crawled" }
}
extension GitHub.RepoMonitor.CrawlingEvent:HTML.OutputStreamable
{
    static
    func += (dl:inout HTML.ContentEncoder, self:Self)
    {
        dl[.dt] = "Package"
        dl[.dd]
        {
            $0[.a] { $0.href = "\(Swiftinit.Tags[self.package])" } = "\(self.package)"
        }

        if  let milliseconds:Milliseconds = self.sinceActual
        {
            let age:Swiftinit.Age = .init(.milliseconds(milliseconds))

            dl[.dt] = "Previously crawled"
            dl[.dd] = age.long
        }

        let error:Swiftinit.Age = .init(.milliseconds(self.sinceExpected))

        dl[.dt] = "Scheduling error"
        dl[.dd] = error.short

        dl[.dt] = "State transition"
        dl[.dd] = self.repo == nil ? "retracted" : "updated"
    }
}
