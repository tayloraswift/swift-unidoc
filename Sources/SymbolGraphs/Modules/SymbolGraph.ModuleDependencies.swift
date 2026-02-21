import Symbols

extension SymbolGraph {
    @frozen public struct ModuleDependencies: Equatable, Hashable, Sendable {
        public var products: [Symbol.Product]
        public var modules: [Int]

        @inlinable public init(products: [Symbol.Product] = [], modules: [Int] = []) {
            self.products = products
            self.modules = modules
        }
    }
}
