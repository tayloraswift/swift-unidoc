import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries
import URI

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
extension Unidoc.RealmEndpoint
{
    static
    subscript(realm:String) -> URI { Unidoc.ServerRoot.realm / realm }
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

        let page:Unidoc.RealmPage = .init(from: output)
        return .ok(page.resource(format: format))
    }
}