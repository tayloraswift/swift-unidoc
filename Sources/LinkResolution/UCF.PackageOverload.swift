import FNV1
import Symbols
import UCF

extension UCF {
    @frozen public struct PackageOverload: ResolvableOverload, Sendable {
        public let traits: DisambiguationTraits
        public let decl: Int32
        public let heir: Int32?

        public let documented: Bool
        public let inherited: Bool
        /// Used for display purposes. This is not necessarily the symbol from which the
        /// ``DisambiguationTraits/hash`` was computed.
        public let id: Symbol.Decl

        @inlinable public init(
            traits: DisambiguationTraits,
            decl: Int32,
            heir: Int32?,
            documented: Bool,
            inherited: Bool,
            id: Symbol.Decl
        ) {
            self.traits = traits
            self.decl = decl
            self.heir = heir
            self.documented = documented
            self.inherited = inherited
            self.id = id
        }
    }
}
