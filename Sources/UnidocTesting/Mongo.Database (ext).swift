import MongoDB
import MongoTesting
import UnidocDB

extension Mongo.Database {
    public func withTemporaryUnidocDatabase(
        logging: Mongo.LogSeverity = .error,
        _ yield: (Unidoc.DB) async throws -> (),
    ) async throws {
        try await Mongo.DriverBootstrap.unidoc.withSessionPool(logger: .init(level: logging)) {
            try await $0.withTemporaryDatabase(self) {
                let unidoc: Unidoc.DB = .init(session: try await .init(from: $0), in: self)
                try await unidoc.setup()
                return try await yield(unidoc)
            }
        }
    }
}
