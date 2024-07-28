import Signatures
import Symbols

extension SSGC
{
    @frozen public
    struct ExtensionSignature:Equatable, Hashable, Sendable
    {
        /// The generic constraints of the relevant extension group.
        /// An empty array represents an unconstrained extension.
        public
        let conditions:[GenericConstraint<Symbol.Decl>]
        /// The type extended by the relevant extension group.
        public
        let extended:ExtendedType

        public
        init(extending extended:ExtendedType, where conditions:[GenericConstraint<Symbol.Decl>])
        {
            self.conditions = conditions
            self.extended = extended
        }
    }
}
extension SSGC.ExtensionSignature:Comparable
{
    public static
    func < (a:Self, b:Self) -> Bool
    {
        if      a.extended < b.extended
        {
            true
        }
        else if a.extended > b.extended
        {
            false
        }
        else
        {
            a.conditions.lexicographicallyPrecedes(b.conditions)
        }
    }
}
