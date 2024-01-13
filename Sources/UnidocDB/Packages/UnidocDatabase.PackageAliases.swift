import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.PackageAliases
{
    public static
    let indexCoordinate:Mongo.CollectionIndex = .init("Coordinate",
        unique: false)
    {
        $0[Unidoc.PackageAlias[.coordinate]] = (+)
    }
}
extension UnidocDatabase.PackageAliases:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PackageAlias

    @inlinable public static
    var name:Mongo.Collection { "PackageAliases" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexCoordinate ] }
}
extension UnidocDatabase.PackageAliases
{
    public
    func insert(alias:Symbol.Package,
        of coordinate:Unidoc.Package,
        with session:Mongo.Session) async throws
    {
        try await self.insert(
            some: Unidoc.PackageAlias.init(id: alias, coordinate: coordinate),
            with: session)
    }
}
