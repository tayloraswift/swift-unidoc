import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    @frozen public
    struct TextEndpoint
    {
        public
        let query:Unidoc.TextResourceQuery<Unidoc.DB.Metadata>
        public
        var value:Unidoc.TextResourceOutput?

        @inlinable public
        init(query:Unidoc.TextResourceQuery<Unidoc.DB.Metadata>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.TextEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .secondaryPreferred }
}
extension Swiftinit.TextEndpoint:Swiftinit.MediaEndpoint
{
    @inlinable public
    var type:MediaType
    {
        switch self.query.id
        {
        case .packages_json:    .application(.json, charset: .utf8)
        case .robots_txt:       .text(.plain, charset: .utf8)
        }
    }
}
extension Swiftinit.TextEndpoint:HTTP.ServerEndpoint
{
}
