import MongoDB
import MongoTesting
import Testing
import UnidocDB

@Suite
struct DatabaseSetup
{
    //  We should be able to reinitialize the database as many times as we want.
    //  (Initialization should be idempotent.)
    @Test
    static func setup() async throws
    {
        try await Mongo.DriverBootstrap.unidoc.withSessionPool(logger: .init(level: .error))
        {
            let database:Mongo.Database = "DatabaseSetup"
            try await $0.withTemporaryDatabase(database)
            {
                let session:Mongo.Session = try await .init(from: $0)

                try await Unidoc.DB.init(session: session, in: database).setup()
                try await Unidoc.DB.init(session: session, in: database).setup()
                try await Unidoc.DB.init(session: session, in: database).setup()
            }
        }
    }
}
