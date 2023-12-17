import HTTP
import SwiftinitRender
import UnidocQueries

extension Unidoc.RealmQuery.Output:HTTP.ServerResponseFactory
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        let page:Swiftinit.RealmPage = .init(from: self)
        return .ok(page.resource(format: format))
    }
}
