import BSON
import GitHubAPI
import JSONEncoding
import MongoDB
import SemanticVersions
import SHA1
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Editions
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Editions:Mongo.CollectionModel
{
    public
    typealias Element = Realm.Edition

    @inlinable public static
    var name:Mongo.Collection { "Editions" }

    public static
    let indexes:[Mongo.CollectionIndex] =
    [
        .init("EditionName",
            collation: SimpleCollation.spec,
            unique: true)
        {
            $0[Realm.Edition[.package]] = (+)
            $0[Realm.Edition[.name]] = (+)
        },

        .init("EditionCoordinate",
            unique: true)
        {
            $0[Realm.Edition[.package]] = (-)
            $0[Realm.Edition[.version]] = (-)
        },

        .init("Nonreleases",
            unique: true)
        {
            $0[Realm.Edition[.package]] = (-)
            $0[Realm.Edition[.patch]] = (-)
            $0[Realm.Edition[.version]] = (-)
        }
            where:
        {
            $0[Realm.Edition[.release]] = .init { $0[.eq] = false }
        },

        .init("Releases",
            unique: true)
        {
            $0[Realm.Edition[.package]] = (-)
            $0[Realm.Edition[.patch]] = (-)
            $0[Realm.Edition[.version]] = (-)
        }
            where:
        {
            $0[Realm.Edition[.release]] = .init { $0[.eq] = true }
        },
    ]
}
extension UnidocDatabase.Editions:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Realm.Edition.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
