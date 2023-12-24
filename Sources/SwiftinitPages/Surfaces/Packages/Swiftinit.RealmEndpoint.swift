import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    @frozen public
    struct RealmEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
    {
        public
        let query:Unidoc.RealmQuery
        public
        var value:Unidoc.RealmQuery.Output?

        @inlinable public
        init(query:Unidoc.RealmQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.RealmEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.RealmQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let page:Swiftinit.RealmPage = .init(from: output)
        return .ok(page.resource(format: format))
    }
}
