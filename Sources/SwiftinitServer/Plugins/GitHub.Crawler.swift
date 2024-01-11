import GitHubAPI
import GitHubClient
import MongoDB

extension GitHub
{
    typealias Crawler = _GitHubCrawler
}
/// The name of this protocol is ``GitHub.Crawler``.
protocol _GitHubCrawler
{
    associatedtype StatusPage:Swiftinit.RenderablePage & Sendable

    var interval:Duration { get }
    var status:StatusPage { get }

    init()

    mutating
    func crawl(updating db:Swiftinit.DB,
        over connection:GitHub.Client<GitHub.API<String>>.Connection,
        with session:Mongo.Session) async throws

    /// Log an error that was not caused by a rate limit.
    mutating
    func log(error:consuming any Error)
}
extension GitHub.Crawler
{
    /// Ignores the error.
    func log(error:consuming any Error)
    {
    }
}
