import LexicalPaths
import Signatures
import Symbols

extension SSGC
{
    final
    class ExtensionObject
    {
        let signature:ExtensionSignature
        /// The full name of the extended type, not including the module namespace prefix.
        let path:UnqualifiedPath

        /// Protocols the extended type conforms to.
        private(set)
        var conformances:[Symbol.Decl: Symbol.Module]
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        private(set)
        var features:[Symbol.Decl: Symbol.Module]
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        private(set)
        var nested:[Symbol.Decl: Symbol.Module]

        /// Documentation comments and source locations for the various extension
        /// blocks that make up this extension.
        var blocks:[Symbol.Block: (Extension.Block, in:Symbol.Module)]

        init(signature:ExtensionSignature, path:UnqualifiedPath)
        {
            self.signature = signature
            self.path = path

            self.conformances = [:]
            self.features = [:]
            self.nested = [:]
            self.blocks = [:]
        }
    }
}
extension SSGC.ExtensionObject
{
    func add(conformance:Symbol.Decl, by culture:Symbol.Module)
    {
        { _ in } (&self.conformances[conformance, default: culture])
    }

    func add(feature:Symbol.Decl, by culture:Symbol.Module)
    {
        { _ in } (&self.features[feature, default: culture])
    }

    func add(nested:Symbol.Decl, by culture:Symbol.Module)
    {
        { _ in } (&self.nested[nested, default: culture])
    }
}
extension SSGC.ExtensionObject
{
    var conditions:[GenericConstraint<Symbol.Decl>] { self.signature.conditions }
    var extended:SSGC.ExtendedType { self.signature.extended }
}
