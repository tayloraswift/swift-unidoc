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
        $0[Unidoc.Group[.id]] = (+)
        $0[Unidoc.Group[.realm]] = (+)
    }

    public static
    let indexScopeRealm:Mongo.CollectionIndex = .init("ScopeRealm",
        unique: false)
    {
        $0[Unidoc.Group[.scope]] = (+)
        $0[Unidoc.Group[.realm]] = (+)
    }

    public static
    let indexScope:Mongo.CollectionIndex = .init("Scope",
        unique: true)
    {
        $0[Unidoc.Group[.scope]] = (+)
        $0[Unidoc.Group[.id]] = (+)
    }
}
extension UnidocDatabase.Groups:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.Group

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
                $0 += groups.autogroups.lazy.map(Unidoc.Group.automatic(_:))
                $0 += groups.topics.lazy.map(Unidoc.Group.topic(_:))

                guard
                let realm:Unidoc.Realm
                else
                {
                    $0 += groups.extensions.lazy.map(Unidoc.Group.extension(_:))
                    return
                }

                for e:Unidoc.Group.Extension in groups.extensions
                {
                    $0[Unidoc.Group.CodingKey.self]
                    {
                        Unidoc.Group.extension(e).encode(to: &$0)

                        $0[.realm] = realm
                    }
                }
            },
            against: self.database)

        return try response.insertions()
    }
}
