import MongoDB
import MongoTesting
import UnidocDatabase

struct PackageNumbers:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Unidoc.Database = try await .setup(database, in: pool)

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await database.package.register("a", with: session).cell ==? 0)
        tests.expect(try await database.package.register("a", with: session).cell ==? 0)
        tests.expect(try await database.package.register("b", with: session).cell ==? 1)
        tests.expect(try await database.package.register("a", with: session).cell ==? 0)
        tests.expect(try await database.package.register("b", with: session).cell ==? 1)
        tests.expect(try await database.package.register("c", with: session).cell ==? 2)
        tests.expect(try await database.package.register("c", with: session).cell ==? 2)
        tests.expect(try await database.package.register("a", with: session).cell ==? 0)
        tests.expect(try await database.package.register("b", with: session).cell ==? 1)
    }
}
