import GitHubAPI
import HTML

extension GitHub.RepoMonitor
{
    enum Event
    {
        case crawl(Crawl)
        case fetch(Fetch)
    }
}
extension GitHub.RepoMonitor.Event:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .crawl(let self):
            div[.h3] = "Repo crawled"
            div[.dl] = self

        case .fetch(let self):
            div[.h3] = "Tags fetched"
            div[.dl] = self
        }
    }
}
