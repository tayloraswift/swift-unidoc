import Symbols
import MongoDB
import UnidocDB
import UnidocRecords

extension UnidocDatabase
{
    public
    func package(named symbol:Symbol.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.execute(
            query: Unidex.PackageQuery.init(symbol: symbol),
            with: session)
    }
    public
    func realm(named symbol:String,
        with session:Mongo.Session) async throws -> Unidoc.RealmMetadata?
    {
        try await self.execute(
            query: Unidex.RealmQuery.init(symbol: symbol),
            with: session)
    }
}
