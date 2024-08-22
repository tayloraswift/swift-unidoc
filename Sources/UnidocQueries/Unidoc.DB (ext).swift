import MongoDB
import SHA1
import Symbols
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc.DB
{
    /// Load the metadata for a package by name. The returned package might have a different
    /// canonical name than the one provided.
    public
    func package(named symbol:Symbol.Package) async throws -> Unidoc.PackageMetadata?
    {
        try await self.query(
            with: Unidoc.AliasResolutionQuery<PackageAliases, Packages>.init(symbol: symbol))
    }
    /// Load the metadata for a realm by name. The returned realm might have a different
    /// canonical name than the one provided.
    public
    func realm(named symbol:String) async throws -> Unidoc.RealmMetadata?
    {
        try await self.query(
            with: Unidoc.AliasResolutionQuery<RealmAliases, Realms>.init(symbol: symbol))
    }

    public
    func edition(package:Symbol.Package,
        version:Unidoc.VersionPredicate) async throws -> Unidoc.EditionOutput?
    {
        try await self.query(
            with: Unidoc.EditionMetadataSymbolicQuery.init(package: package, version: version))
    }

    public
    func editionState(package:Symbol.Package,
        version:Unidoc.VersionPredicate) async throws -> Unidoc.EditionState?
    {
        try await self.query(
            with: Unidoc.EditionStateSymbolicQuery.init(package: package, version: version))
    }

    public
    func editionState(
        of selector:Unidoc.BuildSelector<Unidoc.Package>) async throws -> Unidoc.EditionState?
    {
        switch selector
        {
        case .id(let id):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.EditionStateDirectQuery> = .init(
                query: .init(package: id.package, version: .exact(id.version)))

            try await pipeline.pull(from: self)

            return pipeline.value

        case .latest(let series, of: let package):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.EditionStateDirectQuery> = .init(
                query: .init(package: package, version: .match(.latest(series))))

            try await pipeline.pull(from: self)

            return pipeline.value
        }
    }
}
