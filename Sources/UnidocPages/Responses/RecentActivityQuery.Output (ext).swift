import HTTP
import Media
import UnidocQueries

extension RecentActivityQuery.Output:ServerResponseFactory
{
    public
    func response(as _:AcceptType?) throws -> ServerResponse
    {
        let page:Site.RecentActivity = .init(
            repo: self.repo,
            docs: self.docs)

        return .ok(page.resource())
    }
}
