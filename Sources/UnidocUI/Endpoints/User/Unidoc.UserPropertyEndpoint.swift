import HTTP
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRecords
import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct UserPropertyEndpoint
    {
        public
        let query:UserPropertyQuery
        public
        var value:UserPropertyQuery.Output?

        @inlinable public
        init(query:UserPropertyQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.UserPropertyEndpoint
{
    @inlinable public static
    subscript(account:Unidoc.Account) -> URI { Unidoc.ServerRoot.user / "\(account)" }
}
extension Unidoc.UserPropertyEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.UserPropertyEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.UserPropertyQuery.Output = self.value
        else
        {
            return .notFound("No such user")
        }
        guard
        let name:String = output.user?.name ??
            output.packages.first?.metadata.repo?.origin.owner
        else
        {
            return .notFound("This user has no packages or has not set up her account.")
        }

        let page:Unidoc.UserPropertyPage = .init(user: output.user,
            name: name,
            packages: .init(organizing: output.packages, heading: .free),
            id: self.query.account)

        return .ok(page.resource(format: format))
    }
}
