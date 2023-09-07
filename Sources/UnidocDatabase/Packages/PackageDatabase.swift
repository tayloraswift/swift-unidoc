import MongoDB
import SymbolGraphs
import UnidocAnalysis

@frozen public
struct PackageDatabase:Identifiable, Sendable
{
    public
    let id:Mongo.Database

    @inlinable public
    init(id:Mongo.Database)
    {
        self.id = id
    }
}
extension PackageDatabase
{
    @inlinable public
    var packages:Packages { .init(database: self.id) }
    var editions:Editions { .init(database: self.id) }
    var graphs:Graphs { .init(database: self.id) }
    var meta:Meta { .init(database: self.id) }

    public static
    var collation:Mongo.Collation
    {
        .init(locale: "en", // casing is a property of english, not unicode
            caseLevel: false, // url paths are case-insensitive
            normalization: true, // normalize unicode on insert
            strength: .secondary) // diacritics are significant
    }
}
extension PackageDatabase:DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.packages.setup(with: session)
        try await self.editions.setup(with: session)
        try await self.graphs.setup(with: session)
        try await self.meta.setup(with: session)
    }
}
extension PackageDatabase
{
    public
    func store(docs:Documentation, with session:Mongo.Session) async throws -> SnapshotReceipt
    {
        //  TODO: enforce population limits
        let registration:Packages.Registration = try await self.packages.register(
            docs.metadata.package,
            with: session)

        if  registration.new
        {
            let index:SearchIndex<Never?> = try await self.packages.scan(
                with: session)

            try await self.meta.upsert(index, with: session)
        }

        let zone:Unidoc.Zone

        if  case .sha1(let sha1)? = docs.metadata.revision,
            let refname:String = docs.metadata.refname
        {
            let edition:PackageEdition = .init(id: try await self.editions.zone(
                    package: registration.cell,
                    refname: refname,
                    with: session),
                name: refname,
                sha1: sha1)

            zone = edition.id

            try await self.editions.upsert(edition, with: session)
        }
        else
        {
            zone = .init(package: registration.cell, version: -1)
        }

        return try await self.graphs.store(docs, into: zone, with: session)
    }
}
