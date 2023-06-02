import MongoDB
import MongoTesting
import UnidocDatabase

struct DatabaseSetup:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        //  We should be able to reinitialize the database as many times as we want.
        //  (Initialization should be idempotent.)
        let _:DocumentationDatabase = try await .setup(mongodb: pool, name: database)
        let _:DocumentationDatabase = try await .setup(mongodb: pool, name: database)
        let _:DocumentationDatabase = try await .setup(mongodb: pool, name: database)
    }
}
