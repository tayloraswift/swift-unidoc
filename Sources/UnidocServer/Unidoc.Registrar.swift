import UnidocAPI
import UnidocQueries

extension Unidoc {
    public protocol Registrar<Session>: AnyObject, Sendable {
        associatedtype Session: RegistrarSession

        func connect<T>(
            with access: Unidoc.RegistrarAccessMechanisms,
            _ body: (Session) async throws -> T
        ) async throws -> T

        func resolve(_ edition: RefState, rebuild: Bool) async throws -> BuildLabels?
    }
}
extension Unidoc.Registrar {
    public func run(
        coordinators: [Unidoc.BuildCoordinator],
        in database: Unidoc.Database
    ) async {
        await withTaskGroup(of: Void.self) {
            (tasks: inout TaskGroup<Void>) in

            for coordinator: Unidoc.BuildCoordinator in coordinators {
                tasks.addTask {
                    await coordinator.run(registrar: self, watching: database)
                }
            }

            for await _: Void in tasks {
                tasks.cancelAll()
            }
        }
    }
}
