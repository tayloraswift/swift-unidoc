import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB {
    @frozen public struct Groups {
        public let database: Mongo.Database
        public let session: Mongo.Session

        @inlinable init(database: Mongo.Database, session: Mongo.Session) {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.Groups {
    public static let indexRealm: Mongo.CollectionIndex = .init(
        "Realm",
        unique: true
    ) {
        $0[Unidoc.AnyGroup[.id]] = (+)
        $0[Unidoc.AnyGroup[.realm]] = (+)
    }

    public static let indexScopeRealm: Mongo.CollectionIndex = .init(
        "ScopeRealm",
        unique: false
    ) {
        $0[Unidoc.AnyGroup[.layer]] = (+)
        $0[Unidoc.AnyGroup[.scope]] = (+)
        $0[Unidoc.AnyGroup[.realm]] = (+)
    }

    public static let indexScope: Mongo.CollectionIndex = .init(
        "Scope",
        unique: true
    ) {
        $0[Unidoc.AnyGroup[.layer]] = (+)
        $0[Unidoc.AnyGroup[.scope]] = (+)
        $0[Unidoc.AnyGroup[.id]] = (+)
    }
}
extension Unidoc.DB.Groups: Mongo.CollectionModel {
    public typealias Element = Unidoc.AnyGroup

    @inlinable public static var name: Mongo.Collection { "VolumeGroups" }

    @inlinable public static var indexes: [Mongo.CollectionIndex] {
        [
            Self.indexRealm,
            Self.indexScopeRealm,
            Self.indexScope,
        ]
    }
}
extension Unidoc.DB.Groups {
    @discardableResult
    func insert(
        _ groups: Unidoc.Mesh.Groups,
        realm: Unidoc.Realm?
    ) async throws -> Mongo.Insertions {
        let response: Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(
                Self.name,
                writeConcern: .majority
            ) {
                $0[.ordered] = false
            } documents: {
                //  There should never be a need for intrinsic groups to have realm-level
                //  visibiity.
                $0 += groups.intrinsics.lazy.map(Unidoc.AnyGroup.intrinsic(_:))
                $0 += groups.curators.lazy.map(Unidoc.AnyGroup.curator(_:))

                guard
                let realm: Unidoc.Realm else {
                    $0 += groups.conformers.lazy.map(Unidoc.AnyGroup.conformer(_:))
                    $0 += groups.extensions.lazy.map(Unidoc.AnyGroup.extension(_:))
                    return
                }

                for group: Unidoc.ConformerGroup in groups.conformers {
                    $0[Unidoc.AnyGroup.CodingKey.self] {
                        Unidoc.AnyGroup.conformer(group).encode(to: &$0)

                        $0[.realm] = realm
                    }
                }
                for group: Unidoc.ExtensionGroup in groups.extensions {
                    $0[Unidoc.AnyGroup.CodingKey.self] {
                        Unidoc.AnyGroup.extension(group).encode(to: &$0)

                        $0[.realm] = realm
                    }
                }
            },
            against: self.database,
            by: .now.advanced(by: .seconds(30))
        )

        return try response.insertions()
    }
}
