import HTTP
import Media
import UnidocQueries

extension RecentActivityQuery.Output:HTTP.ServerResponseFactory
{
    public
    func response(as format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        let page:Swiftinit.HomePage = .init(
            repo: self.repo,
            docs: self.docs)

        return .ok(page.resource(format: format))
    }
}
