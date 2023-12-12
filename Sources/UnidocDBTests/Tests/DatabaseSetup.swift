import MongoDB
import MongoTesting
import UnidocDB

struct DatabaseSetup:MongoTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        //  We should be able to reinitialize the database as many times as we want.
        //  (Initialization should be idempotent.)
        await tests.do
        {
            let _:UnidocDatabase = await .setup(as: database, in: pool)
            let _:UnidocDatabase = await .setup(as: database, in: pool)
            let _:UnidocDatabase = await .setup(as: database, in: pool)
        }
    }
}
