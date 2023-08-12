import MongoDB
import MongoTesting
import UnidocDatabase

struct PackageNumbers:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Database = try await .setup(database, in: pool)

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await database.packages.register("a", with: session) ==? 0)
        tests.expect(try await database.packages.register("a", with: session) ==? 0)
        tests.expect(try await database.packages.register("b", with: session) ==? 1)
        tests.expect(try await database.packages.register("a", with: session) ==? 0)
        tests.expect(try await database.packages.register("b", with: session) ==? 1)
        tests.expect(try await database.packages.register("c", with: session) ==? 2)
        tests.expect(try await database.packages.register("c", with: session) ==? 2)
        tests.expect(try await database.packages.register("a", with: session) ==? 0)
        tests.expect(try await database.packages.register("b", with: session) ==? 1)
    }
}
