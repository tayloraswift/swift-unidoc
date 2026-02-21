import MongoDB
import Symbols
import UnidocRecords

extension Unidoc.DB {
    @frozen public struct Search {
        public let database: Mongo.Database
        public let session: Mongo.Session

        @inlinable init(database: Mongo.Database, session: Mongo.Session) {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.Search: Mongo.CollectionModel {
    public typealias Element = Unidoc.TextResource<Symbol.Volume>

    @inlinable public static var name: Mongo.Collection { "VolumeSearch" }

    @inlinable public static var indexes: [Mongo.CollectionIndex] { [] }
}
