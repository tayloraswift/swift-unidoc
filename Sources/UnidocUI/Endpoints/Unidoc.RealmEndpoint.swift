import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries

extension Unidoc
{
    @frozen public
    struct RealmEndpoint
    {
        public
        let query:RealmQuery
        public
        var value:RealmQuery.Output?

        @inlinable public
        init(query:RealmQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.RealmEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.RealmEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
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
