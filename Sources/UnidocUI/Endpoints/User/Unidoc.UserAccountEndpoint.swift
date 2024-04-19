import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries

extension Unidoc
{
    @frozen public
    struct UserAccountEndpoint
    {
        public
        let query:UserAccountQuery
        public
        var value:User?

        @inlinable public
        init(query:UserAccountQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.UserAccountEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.UserAccountEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let user:Unidoc.User = self.value
        else
        {
            return .notFound("No such user")
        }

        let page:Unidoc.UserAccountPage = .init(user: user)
        return .ok(page.resource(format: format))
    }
}
