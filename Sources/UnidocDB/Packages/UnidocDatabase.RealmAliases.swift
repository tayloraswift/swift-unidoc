import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct RealmAliases
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
extension UnidocDatabase.RealmAliases
{
    public static
    let indexRealm:Mongo.CollectionIndex = .init("Realm",
        unique: false)
    {
        $0[Unidex.RealmAlias[.realm]] = (+)
    }
}
extension UnidocDatabase.RealmAliases
{
    public
    typealias Element = Unidex.RealmAlias

    @inlinable public static
    var name:Mongo.Collection { "RealmAliases" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [Self.indexRealm] }
}
