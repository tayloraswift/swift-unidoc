import FNV1
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
    func edition(named symbol:Symbol.PackageAtRef) async throws -> Unidoc.EditionOutput?
    {
        try await self.query(with: Unidoc.EditionMetadataSymbolicQuery.init(
            package: symbol.package,
            version: .name(symbol.ref)))
    }

    public
    func ref(by symbol:Symbol.PackageAtRef) async throws -> Unidoc.RefState?
    {
        try await self.query(with: Unidoc.RefStateSymbolicQuery.init(
            package: symbol.package,
            version: .name(symbol.ref)))
    }

    public
    func ref(of selector:Unidoc.BuildSelector<Unidoc.Package>) async throws -> Unidoc.RefState?
    {
        switch selector
        {
        case .id(let id):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.RefStateDirectQuery> = .init(
                query: .init(package: id.package, version: .exact(id.version)))

            try await pipeline.pull(from: self)

            return pipeline.value

        case .latest(let series, of: let package):
            var pipeline:Mongo.SingleOutputFromPrimary<Unidoc.RefStateDirectQuery> = .init(
                query: .init(package: package, version: .match(.latest(series))))

            try await pipeline.pull(from: self)

            return pipeline.value
        }
    }
}
extension Unidoc.DB
{
    public
    func redirect(exported vertex:Unidoc.VertexPath,
        from volume:Unidoc.Edition) async throws -> Unidoc.RedirectOutput?
    {
        try await self.query(with: Unidoc.RedirectByExportQuery.init(
                volume: volume,
                vertex: vertex),
            on: .nearest)
    }

    public
    func redirect(visited vertex:Unidoc.VertexPath,
        in package:Unidoc.Package) async throws -> Unidoc.RedirectOutput?
    {
        guard
        let visited:Unidoc.SearchbotCell = try await self.searchbotGrid.match(
            vertex: vertex,
            in: package)
        else
        {
            return nil
        }

        guard
        let redirect:Unidoc.RedirectOutput = try await self.query(
            with: Unidoc.RedirectByInternalHintQuery<Unidoc.VertexPath>.init(
                volume: visited.ok,
                lookup: vertex),
            on: .nearest)
        else
        {
            return nil
        }

        return redirect
    }
}
