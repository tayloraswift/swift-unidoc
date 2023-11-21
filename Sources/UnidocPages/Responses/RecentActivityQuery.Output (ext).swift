import HTTP
import Media
import UnidocQueries

extension RecentActivityQuery.Output:HTTP.ServerResponseFactory
{
    public
    func response(with assets:StaticAssets, as _:AcceptType) throws -> HTTP.ServerResponse
    {
        let page:Site.RecentActivity = .init(
            repo: self.repo,
            docs: self.docs)

        return .ok(page.resource(assets: assets))
    }
}
