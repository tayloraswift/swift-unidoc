import Symbols

extension PackageNode {
    @frozen public struct TransitiveDependency: Identifiable {
        public let id: Symbol.Package

        @inlinable public init(id: Symbol.Package) {
            self.id = id
        }
    }
}
