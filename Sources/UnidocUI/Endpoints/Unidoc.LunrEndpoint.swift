import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries

extension Unidoc {
    @frozen public struct LunrEndpoint {
        public let query: TextResourceQuery<DB.Search>
        public var value: TextResourceOutput?

        @inlinable public init(query: Unidoc.TextResourceQuery<DB.Search>) {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.LunrEndpoint: Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint {
    @inlinable public static var replica: Mongo.ReadPreference { .nearest }
}
extension Unidoc.LunrEndpoint: Unidoc.MediaEndpoint {
    @inlinable public var type: MediaType { .application(.json, charset: .utf8) }
}
extension Unidoc.LunrEndpoint: HTTP.ServerEndpoint {
}
