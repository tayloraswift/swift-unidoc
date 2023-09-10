import MongoDB
import MongoTesting
import UnidocDB

/// ``MongoTestBattery`` gives us one temporary database for free, this protocol sets up the
/// other two we need.
protocol UnidocDatabaseTestBattery:MongoTestBattery
{
    func run(_ tests:TestGroup,
        accounts:AccountDatabase,
        packages:PackageDatabase,
        unidoc:UnidocDatabase,
        pool:Mongo.SessionPool) async throws
}
extension UnidocDatabaseTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let accounts:Mongo.Database = .init("\(database)_account")
        let packages:Mongo.Database = .init("\(database)_package")

        try await pool.withTemporaryDatabase(accounts)
        {
            try await pool.withTemporaryDatabase(packages)
            {
                let accounts:AccountDatabase = await .setup(as: accounts, in: pool)
                let packages:PackageDatabase = await .setup(as: packages, in: pool)
                let unidoc:UnidocDatabase = await .setup(as: database, in: pool)

                try await self.run(tests,
                    accounts: accounts,
                    packages: packages,
                    unidoc: unidoc,
                    pool: pool)
            }
        }
    }
}
