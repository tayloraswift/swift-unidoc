import LexicalPaths
import Signatures
import Symbols

extension SSGC
{
    @_eagerMove
    @frozen public
    struct Extension
    {
        public
        let signature:ExtensionSignature
        /// The full name of the extended type, not including the module namespace prefix.
        public
        let path:UnqualifiedPath

        /// Protocols the extended type conforms to.
        public
        var conformances:Set<Symbol.Decl>
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        public
        var features:Set<Symbol.Decl>
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        public
        var nested:Set<Symbol.Decl>
        /// Documentation comments and source locations for the various extension
        /// blocks that make up this extension.
        public internal(set)
        var blocks:[Block]

        init(signature:ExtensionSignature, path:UnqualifiedPath)
        {
            self.signature = signature
            self.path = path

            self.conformances = []
            self.features = []
            self.nested = []
            self.blocks = []
        }
    }
}
extension SSGC.Extension
{
    @inlinable public
    var extended:SSGC.ExtendedType
    {
        self.signature.extended
    }
    @inlinable public
    var conditions:[GenericConstraint<Symbol.Decl>]
    {
        self.signature.conditions
    }
}
