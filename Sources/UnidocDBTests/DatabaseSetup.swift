import MongoDB
import MongoTesting
import UnidocDB

struct DatabaseSetup:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        //  We should be able to reinitialize the database as many times as we want.
        //  (Initialization should be idempotent.)
        if  let tests:TestGroup = tests / "Ecosystem"
        {
            await tests.do
            {
                let _:PackageDatabase = await .setup(as: database, in: pool)
                let _:PackageDatabase = await .setup(as: database, in: pool)
                let _:PackageDatabase = await .setup(as: database, in: pool)
            }
        }
        if  let tests:TestGroup = tests / "Unidoc"
        {
            await tests.do
            {
                let _:UnidocDatabase = await .setup(as: database, in: pool)
                let _:UnidocDatabase = await .setup(as: database, in: pool)
                let _:UnidocDatabase = await .setup(as: database, in: pool)
            }
        }
        if  let tests:TestGroup = tests / "Account"
        {
            await tests.do
            {
                let _:AccountDatabase = await .setup(as: database, in: pool)
                let _:AccountDatabase = await .setup(as: database, in: pool)
                let _:AccountDatabase = await .setup(as: database, in: pool)
            }
        }
    }
}
