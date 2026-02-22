import HTTP
import JSON
import MongoQL
import Symbols
import UnidocDB

extension Unidoc {
    struct BuilderPollOperation: Sendable {
        let builder: Unidoc.Account
        let channel: Symbol.Triple

        init(builder: Unidoc.Account, channel: Symbol.Triple) {
            self.builder = builder
            self.channel = channel
        }
    }
}
extension Unidoc.BuilderPollOperation: Unidoc.MachineOperation {
    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as _: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        /// If the builder is recovering from a crash, kill any builds that had previously been
        /// assigned to it.
        let _: Int = try await db.pendingBuilds.killBuilds(by: self.builder)

        guard
        let coordinator: Unidoc.BuildCoordinator = server.coordinators[self.channel] else {
            return .notFound("Server does not support build target '\(self.channel)'\n")
        }

        let labels: Unidoc.BuildLabels? = try await withThrowingTaskGroup(
            of: Unidoc.BuildLabels?.self
        ) {
            $0.addTask {
                try await Task.sleep(for: .seconds(30 * 60))
                return nil
            }
            $0.addTask {
                try await coordinator.match(builder: self.builder)
            }

            for try await labels: Unidoc.BuildLabels? in $0 {
                $0.cancelAll()
                return labels
            }

            return nil
        }

        guard
        let labels: Unidoc.BuildLabels else {
            //  Return heartbeat.
            return .noContent
        }

        let json: JSON = .object(with: labels.encode(to:))
        return .ok(
            .init(
                content: .init(
                    body: .binary(json.utf8),
                    type: .application(.json, charset: .utf8)
                )
            )
        )
    }
}
