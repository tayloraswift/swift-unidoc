import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    @frozen public
    struct TagsEndpoint
    {
        public
        let query:Unidoc.VersionsQuery
        public
        var value:Unidoc.VersionsQuery.Output?

        @inlinable public
        init(query:Unidoc.VersionsQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.TagsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Swiftinit.TagsEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.VersionsQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let page:Swiftinit.TagsPage = .init(from: output)
        return .ok(page.resource(format: format))
    }
}
