import FNV1
import SymbolGraphs
import Symbols
import UnidocAPI

extension Unidoc {
    @frozen public struct ProductVertex: Identifiable, Equatable, Sendable {
        public let id: Unidoc.Scalar
        public let constituents: [Unidoc.Scalar]
        public let symbol: String
        public let type: SymbolGraph.ProductType

        public var group: Unidoc.Group?

        @inlinable public init(
            id: Unidoc.Scalar,
            constituents: [Unidoc.Scalar],
            symbol: String,
            type: SymbolGraph.ProductType,
            group: Unidoc.Group?
        ) {
            self.id = id
            self.constituents = constituents
            self.symbol = symbol
            self.type = type
            self.group = group
        }
    }
}
extension Unidoc.ProductVertex: Unidoc.PrincipalVertex {
    @inlinable public var overview: Unidoc.Passage? { nil }

    @inlinable public var details: Unidoc.Passage? { nil }

    @inlinable public var stem: Unidoc.Stem { .product(self.symbol) }

    @inlinable public var hash: FNV24.Extended { .product(self.symbol) }

    @inlinable public var bias: Unidoc.Bias { .neutral }

    @inlinable public var decl: Phylum.DeclFlags? { nil }
}
