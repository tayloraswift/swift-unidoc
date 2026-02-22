import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocQueries

extension Unidoc {
    @frozen public struct TextEndpoint {
        public let query: Unidoc.TextResourceQuery<Unidoc.DB.Metadata>
        public var value: Unidoc.TextResourceOutput?

        @inlinable public init(query: Unidoc.TextResourceQuery<Unidoc.DB.Metadata>) {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.TextEndpoint: Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint {
    @inlinable public static var replica: Mongo.ReadPreference { .nearest }
}
extension Unidoc.TextEndpoint: Unidoc.MediaEndpoint {
    @inlinable public var type: MediaType {
        switch self.query.id {
        case .packages_json:    .application(.json, charset: .utf8)
        case .robots_txt:       .text(.plain, charset: .utf8)
        }
    }
}
extension Unidoc.TextEndpoint: HTTP.ServerEndpoint {
}
