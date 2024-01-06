import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Groups
    {
        public
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Groups
{
    public static
    let indexRealm:Mongo.CollectionIndex = .init("Realm",
        unique: true)
    {
        $0[Unidoc.AnyGroup[.id]] = (+)
        $0[Unidoc.AnyGroup[.realm]] = (+)
    }

    public static
    let indexScopeRealm:Mongo.CollectionIndex = .init("ScopeRealm",
        unique: false)
    {
        $0[Unidoc.AnyGroup[.layer]] = (+)
        $0[Unidoc.AnyGroup[.scope]] = (+)
        $0[Unidoc.AnyGroup[.realm]] = (+)
    }

    public static
    let indexScope:Mongo.CollectionIndex = .init("Scope",
        unique: true)
    {
        $0[Unidoc.AnyGroup[.layer]] = (+)
        $0[Unidoc.AnyGroup[.scope]] = (+)
        $0[Unidoc.AnyGroup[.id]] = (+)
    }
}
extension UnidocDatabase.Groups:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.AnyGroup

    @inlinable public static
    var name:Mongo.Collection { "VolumeGroups" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexRealm,
            Self.indexScopeRealm,
            Self.indexScope,
        ]
    }
}
extension UnidocDatabase.Groups
{
    @discardableResult
    func insert(_ groups:Unidoc.Volume.Groups,
        realm:Unidoc.Realm?,
        with session:Mongo.Session) async throws -> Mongo.Insertions
    {
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority)
            {
                $0[.ordered] = false
            }
                documents:
            {
                $0 += groups.polygons.lazy.map(Unidoc.AnyGroup.polygonal(_:))
                $0 += groups.topics.lazy.map(Unidoc.AnyGroup.topic(_:))

                guard
                let realm:Unidoc.Realm
                else
                {
                    $0 += groups.conformers.lazy.map(Unidoc.AnyGroup.conformers(_:))
                    $0 += groups.extensions.lazy.map(Unidoc.AnyGroup.extension(_:))
                    return
                }

                for group:Unidoc.ConformerGroup in groups.conformers
                {
                    $0[Unidoc.AnyGroup.CodingKey.self]
                    {
                        Unidoc.AnyGroup.conformers(group).encode(to: &$0)

                        $0[.realm] = realm
                    }
                }
                for group:Unidoc.ExtensionGroup in groups.extensions
                {
                    $0[Unidoc.AnyGroup.CodingKey.self]
                    {
                        Unidoc.AnyGroup.extension(group).encode(to: &$0)

                        $0[.realm] = realm
                    }
                }
            },
            against: self.database)

        return try response.insertions()
    }
}
