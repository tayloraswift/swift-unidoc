import HTTP
import Media
import SwiftinitRender
import UnidocQueries

extension Unidoc.ActivityQuery.Output:HTTP.ServerResponseFactory
{
    public
    func response(as format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        let page:Swiftinit.HomePage = .init(
            repo: self.repo,
            docs: self.docs)

        return .ok(page.resource(format: format))
    }
}
