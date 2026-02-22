import LexicalPaths
import Symbols
import UCF

extension UCF {
    @frozen @usableFromInline struct ResolutionPath: Equatable, Hashable, Sendable {
        @usableFromInline let string: String

        @inlinable init(string: String) {
            self.string = string
        }
    }
}
extension UCF.ResolutionPath {
    func lowercased() -> Self { .init(string: self.string.lowercased()) }
}
extension UCF.ResolutionPath {
    @inlinable init(_ namespace: Symbol.Module) {
        self.init(string: "\(namespace)")
    }

    @inlinable static func join(
        _ namespace: Symbol.Module,
        _ path: UnqualifiedPath,
        _ last: String
    ) -> Self {
        .init(string: "\(namespace) \(path.joined(separator: " ")) \(last)")
    }
    @inlinable static func join(_ namespace: Symbol.Module, _ path: UnqualifiedPath) -> Self {
        .init(string: "\(namespace) \(path.joined(separator: " "))")
    }
    @inlinable static func join(_ components: [String]) -> Self {
        .init(string: components.joined(separator: " "))
    }
}
