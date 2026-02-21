import LexicalPaths
import Signatures
import Symbols

extension SSGC {
    @frozen public struct Extension: Equatable {
        public let conditions: [GenericConstraint<Symbol.Decl>]
        public let extendee: Extendee

        /// Protocols the extended type conforms to.
        public internal(set) var conformances: [Symbol.Decl]
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        public internal(set) var features: [Symbol.Decl]
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        public internal(set) var nested: [Symbol.Decl]
        /// Documentation comments and source locations for the various extension
        /// blocks that make up this extension.
        public internal(set) var blocks: [Block]

        init(
            conditions: [GenericConstraint<Symbol.Decl>],
            extendee: Extendee,
            conformances: [Symbol.Decl],
            features: [Symbol.Decl],
            nested: [Symbol.Decl],
            blocks: [Block]
        ) {
            self.conditions = conditions
            self.extendee = extendee

            self.conformances = conformances
            self.features = features
            self.nested = nested
            self.blocks = blocks
        }
    }
}
extension SSGC.Extension {
    var id: ID { .init(extending: self.extendee.id, where: self.conditions) }
}
