import MongoDB
import MongoTesting
import UnidocDatabase

struct PackageNumbers:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:PackageDatabase = await .setup(as: database, in: pool)
        let packages:PackageDatabase.Packages = database.packages

        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await packages.register("a", with: session) ==? 0)
        tests.expect(try await packages.register("a", with: session) ==? 0)
        tests.expect(try await packages.register("b", with: session) ==? 1)
        tests.expect(try await packages.register("a", with: session) ==? 0)
        tests.expect(try await packages.register("b", with: session) ==? 1)
        tests.expect(try await packages.register("c", with: session) ==? 2)
        tests.expect(try await packages.register("c", with: session) ==? 2)
        tests.expect(try await packages.register("a", with: session) ==? 0)
        tests.expect(try await packages.register("b", with: session) ==? 1)
    }
}
