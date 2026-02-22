import MongoDB
import MongoTesting
import UnidocDB

extension Unidoc {
    public protocol TestBattery {
        func run(with db: Unidoc.DB) async throws
    }
}
extension Unidoc.TestBattery {
    public func run(
        in database: Mongo.Database,
        logging: Mongo.LogSeverity = .error
    ) async throws {
        try await Mongo.DriverBootstrap.unidoc.withSessionPool(logger: .init(level: logging)) {
            try await $0.withTemporaryDatabase(database) {
                let unidoc: Unidoc.DB = .init(session: try await .init(from: $0), in: database)
                try await unidoc.setup()
                try await self.run(with: unidoc)
            }
        }
    }
}
