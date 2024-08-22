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
            try await Unidoc.DB.init(session: try await .init(from: pool), in: database).setup()
            try await Unidoc.DB.init(session: try await .init(from: pool), in: database).setup()
            try await Unidoc.DB.init(session: try await .init(from: pool), in: database).setup()
        }
    }
}
