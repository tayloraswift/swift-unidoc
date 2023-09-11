import MongoDB
import MongoTesting

@_spi(testable)
import UnidocDB

struct PackageNumbers:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:PackageDatabase = await .setup(as: database, in: pool)
        let session:Mongo.Session = try await .init(from: pool)

        tests.expect(try await database.track(package: "a", with: session) ==? 0)
        tests.expect(try await database.track(package: "a", with: session) ==? 0)
        tests.expect(try await database.track(package: "b", with: session) ==? 1)
        tests.expect(try await database.track(package: "a", with: session) ==? 0)
        tests.expect(try await database.track(package: "b", with: session) ==? 1)
        tests.expect(try await database.track(package: "c", with: session) ==? 2)
        tests.expect(try await database.track(package: "c", with: session) ==? 2)
        tests.expect(try await database.track(package: "a", with: session) ==? 0)
        tests.expect(try await database.track(package: "b", with: session) ==? 1)
    }
}
