import HTTP
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    @frozen public
    struct HomeEndpoint
    {
        public
        let query:Unidoc.ActivityQuery
        public
        var value:Unidoc.ActivityQuery.Output?

        @inlinable public
        init(query:Unidoc.ActivityQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.HomeEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Swiftinit.HomeEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.ActivityQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let page:Swiftinit.HomePage = .init(
            repo: output.repo,
            docs: output.docs)

        return .ok(page.resource(format: format))
    }
}
