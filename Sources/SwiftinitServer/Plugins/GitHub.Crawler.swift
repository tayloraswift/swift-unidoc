import GitHubAPI
import GitHubClient
import MongoDB

extension GitHub
{
    /// The name of this protocol is ``GitHub.Crawler``.
    protocol Crawler
    {
        associatedtype StatusPage:Unidoc.RenderablePage & Sendable

        var interval:Duration { get }
        var status:StatusPage { get }

        init()

        mutating
        func crawl(updating db:Unidoc.Database,
            over connection:GitHub.Client<GitHub.API<String>>.Connection,
            with session:Mongo.Session) async throws

        /// Log an error that was not caused by a rate limit.
        var error:(any Error)? { get set }
    }
}
