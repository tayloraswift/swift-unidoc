import Symbols

extension SymbolGraphMetadata {
    @frozen public struct Package: Equatable, Sendable {
        public var scope: Symbol.PackageScope?
        public var name: Symbol.Package

        @inlinable public init(scope: Symbol.PackageScope? = nil, name: Symbol.Package) {
            self.scope = scope
            self.name = name
        }
    }
}
extension SymbolGraphMetadata.Package: Identifiable {
    @inlinable public var id: Symbol.Package { self.scope.map { $0 | self.name } ?? self.name }
}
