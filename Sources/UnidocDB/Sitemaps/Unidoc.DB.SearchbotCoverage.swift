import BSON
import MongoDB
import MongoQL
import UnidocRecords

extension Unidoc.DB {
    @frozen public struct SearchbotCoverage {
        public let database: Mongo.Database
        public let session: Mongo.Session

        @inlinable init(database: Mongo.Database, session: Mongo.Session) {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.SearchbotCoverage: Mongo.CollectionModel {
    public typealias Element = Unidoc.SearchbotStats

    @inlinable public static var name: Mongo.Collection { "SearchbotCoverage" }

    @inlinable public static var indexes: [Mongo.CollectionIndex] { [] }
}
