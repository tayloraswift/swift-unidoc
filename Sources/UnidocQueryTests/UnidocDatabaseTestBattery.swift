import MongoDB
import MongoTesting
import UnidocDB

/// ``MongoTestBattery`` gives us one temporary database for free, this protocol sets up the
/// other one we need.
protocol UnidocDatabaseTestBattery:MongoTestBattery
{
    func run(_ tests:TestGroup,
        accounts:AccountDatabase,
        unidoc:UnidocDatabase,
        pool:Mongo.SessionPool) async throws
}
extension UnidocDatabaseTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let accounts:Mongo.Database = .init("\(database)_account")

        try await pool.withTemporaryDatabase(accounts)
        {
            let accounts:AccountDatabase = await .setup(as: accounts, in: pool)
            let unidoc:UnidocDatabase = await .setup(as: database, in: pool)

            try await self.run(tests,
                accounts: accounts,
                unidoc: unidoc,
                pool: pool)
        }
    }
}
