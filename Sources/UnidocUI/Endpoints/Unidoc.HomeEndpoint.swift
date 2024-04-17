import HTTP
import Media
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries

extension Unidoc
{
    @frozen public
    struct HomeEndpoint
    {
        public
        let query:ActivityQuery
        public
        var value:ActivityQuery.Output?

        @inlinable public
        init(query:ActivityQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.HomeEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.HomeEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
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
