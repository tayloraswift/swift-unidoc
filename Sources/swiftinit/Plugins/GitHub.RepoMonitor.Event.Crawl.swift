import Durations
import GitHubAPI
import HTML
import UnidocUI
import Symbols

extension GitHub.RepoMonitor.Event
{
    struct Crawl
    {
        let package:Symbol.Package

        let sinceExpected:Milliseconds?
        let sinceActual:Milliseconds?
        let repo:GitHub.Repo?

        init(package:Symbol.Package,
            sinceExpected:Milliseconds?,
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
extension GitHub.RepoMonitor.Event.Crawl:HTML.OutputStreamable
{
    static
    func += (dl:inout HTML.ContentEncoder, self:Self)
    {
        dl[.dt] = "Package"
        dl[.dd]
        {
            $0[.a] { $0.href = "\(Unidoc.TagsEndpoint[self.package])" } = "\(self.package)"
        }

        if  let milliseconds:Milliseconds = self.sinceActual
        {
            let age:Duration.DynamicFormat = .init(truncating: .milliseconds(milliseconds))

            dl[.dt] = "Previously crawled"
            dl[.dd] = "\(age) ago"
        }
        if  let milliseconds:Milliseconds = self.sinceExpected
        {
            let error:Duration.DynamicFormat = .init(truncating: .milliseconds(milliseconds))

            dl[.dt] = "Scheduling error"
            dl[.dd] = error.short
        }

        dl[.dt] = "State transition"
        dl[.dd] = self.repo == nil ? "retracted" : "updated"
    }
}
