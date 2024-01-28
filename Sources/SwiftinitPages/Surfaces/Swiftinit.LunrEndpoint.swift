import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    @frozen public
    struct LunrEndpoint
    {
        public
        let query:Unidoc.TextResourceQuery<Unidoc.DB.Search>
        public
        var value:Unidoc.TextResourceOutput?

        @inlinable public
        init(query:Unidoc.TextResourceQuery<Unidoc.DB.Search>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.LunrEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .secondaryPreferred }
}
extension Swiftinit.LunrEndpoint:Swiftinit.MediaEndpoint
{
    @inlinable public
    var type:MediaType { .application(.json, charset: .utf8) }
}
extension Swiftinit.LunrEndpoint:HTTP.ServerEndpoint
{
}
