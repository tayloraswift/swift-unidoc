import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    @frozen public
    struct AccountEndpoint
    {
        public
        let query:Unidoc.UserQuery
        public
        var value:Unidoc.User?

        @inlinable public
        init(query:Unidoc.UserQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.AccountEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Swiftinit.AccountEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let user:Unidoc.User = self.value
        else
        {
            return .notFound("No such user")
        }

        let page:Swiftinit.UserPage = .init(user: user)
        return .ok(page.resource(format: format))
    }
}
