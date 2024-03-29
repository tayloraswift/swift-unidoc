import BSON
import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc.DB
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
extension Unidoc.DB.RealmAliases
{
    public static
    let indexCoordinate:Mongo.CollectionIndex = .init("Coordinate",
        unique: false)
    {
        $0[Unidoc.RealmAlias[.coordinate]] = (+)
    }
}
extension Unidoc.DB.RealmAliases:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.RealmAlias

    @inlinable public static
    var name:Mongo.Collection { "RealmAliases" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [Self.indexCoordinate] }
}
extension Unidoc.DB.RealmAliases
{
    public
    func insert(alias:String,
        of coordinate:Unidoc.Realm,
        with session:Mongo.Session) async throws
    {
        try await self.insert(
            some: Unidoc.RealmAlias.init(id: alias, coordinate: coordinate),
            with: session)
    }
}
