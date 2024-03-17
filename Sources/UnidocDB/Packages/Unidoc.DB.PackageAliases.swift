import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct PackageAliases
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
extension Unidoc.DB.PackageAliases
{
    public static
    let indexCoordinate:Mongo.CollectionIndex = .init("Coordinate",
        unique: false)
    {
        $0[Unidoc.PackageAlias[.coordinate]] = (+)
    }
}
extension Unidoc.DB.PackageAliases:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PackageAlias

    @inlinable public static
    var name:Mongo.Collection { "PackageAliases" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexCoordinate ] }
}
extension Unidoc.DB.PackageAliases
{
    public
    func upsert(alias:Symbol.Package,
        of coordinate:Unidoc.Package,
        with session:Mongo.Session) async throws
    {
        try await self.upsert(
            some: Unidoc.PackageAlias.init(id: alias, coordinate: coordinate),
            with: session)
    }

    func insert(alias:Symbol.Package,
        of coordinate:Unidoc.Package,
        with session:Mongo.Session) async throws
    {
        try await self.insert(
            some: Unidoc.PackageAlias.init(id: alias, coordinate: coordinate),
            with: session)
    }
}
