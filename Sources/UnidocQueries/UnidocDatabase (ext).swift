import MongoDB
import Symbols
import UnidocDB
import UnidocRecords

extension UnidocDatabase
{
    public
    func package(named symbol:Symbol.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.execute(
            query: Unidoc.AliasResolutionQuery<PackageAliases, Packages>.init(symbol: symbol),
            with: session)
    }
    public
    func realm(named symbol:String,
        with session:Mongo.Session) async throws -> Unidoc.RealmMetadata?
    {
        try await self.execute(
            query: Unidoc.AliasResolutionQuery<RealmAliases, Realms>.init(symbol: symbol),
            with: session)
    }
}
