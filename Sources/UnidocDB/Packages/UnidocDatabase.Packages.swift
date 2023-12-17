import BSON
import JSON
import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Packages
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
extension UnidocDatabase.Packages
{
    public static
    let indexLastCrawled:Mongo.CollectionIndex = .init("LastCrawled", unique: false)
    {
        $0[Unidoc.PackageMetadata[.crawled]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.repo]] = .init { $0[.exists] = true }
    }

    public static
    let indexRealm:Mongo.CollectionIndex = .init("Realm", unique: false)
    {
        $0[Unidoc.PackageMetadata[.realm]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.realm]] = .init { $0[.exists] = true }
    }
}
extension UnidocDatabase.Packages:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PackageMetadata

    @inlinable public static
    var name:Mongo.Collection { "Packages" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexLastCrawled,
            Self.indexRealm,
        ]
    }
}
extension UnidocDatabase.Packages:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.PackageMetadata.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension UnidocDatabase.Packages
{
    public
    func update(record:Unidoc.PackageMetadata, with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(some: record, with: session)
    }

    public
    func stalest(_ limit:Int,
        with session:Mongo.Session) async throws -> [Unidoc.PackageMetadata]
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Unidoc.PackageMetadata>>.init(Self.name,
                limit: limit)
            {
                $0[.filter] = .init
                {
                    $0[Unidoc.PackageMetadata[.repo]] = .init { $0[.exists] = true }
                }
                $0[.sort] = .init
                {
                    $0[Unidoc.PackageMetadata[.crawled]] = (+)
                }
                $0[.hint] = .init
                {
                    $0[Unidoc.PackageMetadata[.crawled]] = (+)
                }
            },
            against: self.database)
    }
}
extension UnidocDatabase.Packages
{
    func scan(with session:Mongo.Session) async throws -> SearchIndex<Int32>
    {
        //  TODO: this should project the `_id`
        let json:JSON = try await .array
        {
            (json:inout JSON.ArrayEncoder) in

            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Unidoc.PackageMetadata>>.init(Self.name,
                    stride: 1024),
                against: self.database)
            {
                for try await batch:[Unidoc.PackageMetadata] in $0
                {
                    for cell:Unidoc.PackageMetadata in batch
                    {
                        json[+] = "\(cell.symbol)"
                    }
                }
            }
        }

        return .init(id: 0, json: json)
    }
}
