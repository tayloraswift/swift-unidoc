import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries

extension Unidoc
{
    @frozen public
    struct UserEndpoint
    {
        public
        let query:UserQuery
        public
        var value:User?

        @inlinable public
        init(query:UserQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.UserEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.UserEndpoint:HTTP.ServerEndpoint
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

        let page:Unidoc.UserPage = .init(user: user)
        return .ok(page.resource(format: format))
    }
}
