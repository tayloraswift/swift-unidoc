import Atomics
import HTML
import UnidocDB
import UnidocRender

extension Unidoc {
    public protocol Plugin: Sendable {
        /// Restart cooldown.
        static var cooldown: Duration { get }
        static var title: String { get }
        static var id: String { get }

        var enabledInitially: Bool { get }

        func run(in context: PluginContext) async throws -> Duration?
    }
}
extension Unidoc.Plugin {
    @inlinable public var enabledInitially: Bool { true }

    @inlinable public static var cooldown: Duration { .seconds(5) }
}
