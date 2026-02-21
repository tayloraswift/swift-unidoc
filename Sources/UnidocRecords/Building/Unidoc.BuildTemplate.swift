import SemanticVersions
import Symbols

extension Unidoc {
    @frozen public struct BuildTemplate: Equatable, Sendable {
        public var toolchain: PatchVersion?
        public var platform: Symbol.Triple?

        @inlinable public init() {
        }

        @inlinable public init(toolchain: PatchVersion?, platform: Symbol.Triple?) {
            self.toolchain = toolchain
            self.platform = platform
        }
    }
}
