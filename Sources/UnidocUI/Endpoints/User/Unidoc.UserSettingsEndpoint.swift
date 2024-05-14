import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries

extension Unidoc
{
    @frozen public
    struct UserSettingsEndpoint
    {
        public
        let query:UserAccountQuery
        public
        var value:UserAccountQuery.Output?

        @inlinable public
        init(query:UserAccountQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.UserSettingsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.UserSettingsEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.UserAccountQuery.Output = self.value
        else
        {
            return .notFound("No such user")
        }

        let page:Unidoc.UserSettingsPage = .init(user: output.user,
            organizations: output.organizations)
        return .ok(page.resource(format: format))
    }
}
