import BSON
import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc.DB {
    @frozen public struct RealmAliases {
        public let database: Mongo.Database
        public let session: Mongo.Session

        @inlinable init(database: Mongo.Database, session: Mongo.Session) {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.RealmAliases {
    public static let indexCoordinate: Mongo.CollectionIndex = .init(
        "Coordinate",
        unique: false
    ) {
        $0[Unidoc.RealmAlias[.coordinate]] = (+)
    }
}
extension Unidoc.DB.RealmAliases: Mongo.CollectionModel {
    public typealias Element = Unidoc.RealmAlias

    @inlinable public static var name: Mongo.Collection { "RealmAliases" }

    @inlinable public static var indexes: [Mongo.CollectionIndex] { [Self.indexCoordinate] }
}
extension Unidoc.DB.RealmAliases {
    @inlinable public func insert(
        alias: String,
        of coordinate: Unidoc.Realm
    ) async throws {
        try await self.insert(.init(id: alias, coordinate: coordinate))
    }
}
