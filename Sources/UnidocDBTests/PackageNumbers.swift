import MongoDB
import MongoTesting
import Symbols
import UnidocDB
import UnidocRecords

struct PackageNumbers:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:UnidocDatabase = await .setup(as: database, in: pool)
        let session:Mongo.Session = try await .init(from: pool)

        for expected:(symbol:Symbol.Package, id:Unidoc.Package, new:Bool) in
        [
            ("a", 0, true),
            ("b", 1, true),
            ("a", 0, false),
            ("b", 1, false),
            ("c", 2, true),
            ("c", 2, false),
            ("a", 0, false),
            ("b", 1, false),
        ]
        {
            let (package, new):(Realm.Package, Bool) = try await database.register(
                expected.symbol,
                with: session)

            tests.expect(package.id ==? expected.id)
            tests.expect(new ==? expected.new)
        }
    }
}
