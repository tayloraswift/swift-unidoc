import Signatures
import Unidoc

extension Unidoc {
    @frozen public struct ConformerGroup: Identifiable, Equatable, Sendable {
        public let id: Group
        public let culture: Scalar
        public let scope: Scalar

        public var unconditional: [Unidoc.Scalar]
        public var conditional: [ConformingType]

        @inlinable public init(
            id: Group,
            culture: Scalar,
            scope: Scalar,
            unconditional: [Unidoc.Scalar] = [],
            conditional: [ConformingType] = []
        ) {
            self.id = id
            self.culture = culture
            self.scope = scope
            self.unconditional = unconditional
            self.conditional = conditional
        }
    }
}
extension Unidoc.ConformerGroup {
    @inlinable public var count: Int {
        self.unconditional.count + self.conditional.count
    }
}
