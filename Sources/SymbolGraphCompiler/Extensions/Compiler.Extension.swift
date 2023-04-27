import Generics
import LexicalPaths

extension Compiler
{
    @frozen public
    struct Extension
    {
        /// Protocols the extended type conforms to.
        public
        var conformances:Set<Symbol.Scalar>
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        public
        var features:Set<Symbol.Scalar>
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        public
        var nested:Set<Symbol.Scalar>
        /// Documentation comments and source locations for the various extension
        /// blocks that make up this extension.
        public
        var blocks:[Block]

        public
        let signature:Signature

        init(signature:Signature)
        {
            self.signature = signature

            self.conformances = []
            self.features = []
            self.nested = []
            self.blocks = []
        }
    }
}
extension Compiler.Extension
{
    @inlinable public
    var extendee:Symbol.Scalar
    {
        self.signature.type
    }
    @inlinable public
    var conditions:[GenericConstraint<Symbol.Scalar>]
    {
        self.signature.conditions
    }
}
