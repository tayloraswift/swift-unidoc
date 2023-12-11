import MongoDB
import MongoTesting
import UnidocDB

protocol UnidocDatabaseTestBattery:MongoTestBattery
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, unidoc:UnidocDatabase) async throws
}
extension UnidocDatabaseTestBattery
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let unidoc:UnidocDatabase = await .setup(as: database, in: pool)
        try await Self.run(tests: tests, pool: pool, unidoc: unidoc)
    }
}
