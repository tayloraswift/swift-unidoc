import Signatures
import Symbols

extension SSGC
{
    struct ExtensionSignature:Equatable, Hashable, Sendable
    {
        /// The generic constraints of the relevant extension group.
        /// An empty set represents an unconstrained extension.
        let conditions:Set<GenericConstraint<Symbol.Decl>>
        /// The type extended by the relevant extension group.
        let extendee:Symbol.Decl

        init(extending extendee:Symbol.Decl,
            where conditions:Set<GenericConstraint<Symbol.Decl>>)
        {
            self.conditions = conditions
            self.extendee = extendee
        }
    }
}
