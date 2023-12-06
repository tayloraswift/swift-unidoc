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
    let indexRealm:Mongo.CollectionIndex = .init("Unidex",
        unique: true)
    {
        $0[Volume.Group[.id]] = (+)
        $0[Volume.Group[.realm]] = (+)
    }

    public static
    let indexScopeRealm:Mongo.CollectionIndex = .init("ScopeRealm",
        unique: false)
    {
        $0[Volume.Group[.scope]] = (+)
        $0[Volume.Group[.realm]] = (+)
    }

    public static
    let indexScope:Mongo.CollectionIndex = .init("Scope",
        unique: true)
    {
        $0[Volume.Group[.scope]] = (+)
        $0[Volume.Group[.id]] = (+)
    }
}
extension UnidocDatabase.Groups:Mongo.CollectionModel
{
    public
    typealias Element = Volume.Group

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
    func insert(_ groups:Volume.Groups,
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
                $0 += groups.autogroups.lazy.map(Volume.Group.automatic(_:))
                $0 += groups.topics.lazy.map(Volume.Group.topic(_:))

                guard
                let realm:Unidoc.Realm
                else
                {
                    $0 += groups.extensions.lazy.map(Volume.Group.extension(_:))
                    return
                }

                for e:Volume.Group.Extension in groups.extensions
                {
                    $0[Volume.Group.CodingKey.self]
                    {
                        Volume.Group.extension(e).encode(to: &$0)

                        $0[.realm] = realm
                    }
                }
            },
            against: self.database)

        return try response.insertions()
    }
}
