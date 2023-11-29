import BSON
import BSONDecoding
import BSONEncoding
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
    let indexLastCrawled:Mongo.CollectionIndex = .init("LastCrawled")
    {
        $0[Realm.Package[.crawled]] = (+)
    }
        where:
    {
        $0[Realm.Package[.repo]] = .init { $0[.exists] = true }
    }
}
extension UnidocDatabase.Packages:Mongo.CollectionModel
{
    public
    typealias Element = Realm.Package

    @inlinable public static
    var name:Mongo.Collection { "Packages" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexLastCrawled ] }
}
extension UnidocDatabase.Packages:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Realm.Package.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension UnidocDatabase.Packages
{
    public
    func update(record:Realm.Package, with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(some: record, with: session)
    }

    public
    func stalest(_ limit:Int, with session:Mongo.Session) async throws -> [Realm.Package]
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Realm.Package>>.init(Self.name,
                limit: limit)
            {
                $0[.filter] = .init
                {
                    $0[Realm.Package[.repo]] = .init { $0[.exists] = true }
                }
                $0[.sort] = .init
                {
                    $0[Realm.Package[.crawled]] = (+)
                }
                $0[.hint] = .init
                {
                    $0[Realm.Package[.crawled]] = (+)
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
                command: Mongo.Find<Mongo.Cursor<Realm.Package>>.init(Self.name, stride: 1024),
                against: self.database)
            {
                for try await batch:[Realm.Package] in $0
                {
                    for cell:Realm.Package in batch
                    {
                        json[+] = "\(cell.symbol)"
                    }
                }
            }
        }

        return .init(id: 0, json: json)
    }
}
