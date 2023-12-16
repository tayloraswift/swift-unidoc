import MongoDB
import Symbols
import UnidocDB
import UnidocRecords

extension UnidocDatabase
{
    /// Load the metadata for a package by name. The returned package might have a different
    /// canonical name than the one provided.
    public
    func package(named symbol:Symbol.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.execute(
            query: Unidoc.AliasResolutionQuery<PackageAliases, Packages>.init(symbol: symbol),
            with: session)
    }
    /// Load the metadata for a realm by name. The returned realm might have a different
    /// canonical name than the one provided.
    public
    func realm(named symbol:String,
        with session:Mongo.Session) async throws -> Unidoc.RealmMetadata?
    {
        try await self.execute(
            query: Unidoc.AliasResolutionQuery<RealmAliases, Realms>.init(symbol: symbol),
            with: session)
    }
}
