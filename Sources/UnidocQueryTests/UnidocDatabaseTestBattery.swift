import MongoDB
import MongoTesting
import UnidocDB

protocol UnidocDatabaseTestBattery:MongoTestBattery
{
    static
    func run(tests:TestGroup, db:Unidoc.DB) async throws
}
extension UnidocDatabaseTestBattery
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let unidoc:Unidoc.DB = .init(session: try await .init(from: pool), in: database)
        try await unidoc.setup()
        try await Self.run(tests: tests, db: unidoc)
    }
}
