import FNV1
import Symbols
import UCF

extension UCF {
    @frozen public struct CausalOverload: ResolvableOverload, Sendable {
        public let traits: DisambiguationTraits
        public let decl: Symbol.Decl
        public let heir: Symbol.Decl?

        public let documented: Bool
        public let inherited: Bool

        @inlinable public init(
            traits: DisambiguationTraits,
            decl: Symbol.Decl,
            heir: Symbol.Decl?,
            documented: Bool,
            inherited: Bool
        ) {
            self.traits = traits
            self.decl = decl
            self.heir = heir
            self.documented = documented
            self.inherited = inherited
        }
    }
}
extension UCF.CausalOverload: Identifiable {
    @inlinable public var id: Symbol.Decl { self.decl }
}
