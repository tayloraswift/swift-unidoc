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
        let culture:Int

        public
        init(_ culture:Int, _ extended:ExtendedType,
            where conditions:[GenericConstraint<Symbol.Decl>])
        {
            self.conditions = conditions
            self.culture = culture
            self.extended = extended
        }
    }
}
extension SSGC.ExtensionSignature:Comparable
{
    public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        if      (lhs.culture, lhs.extended) < (rhs.culture, rhs.extended)
        {
            true
        }
        else if (lhs.culture, lhs.extended) > (rhs.culture, rhs.extended)
        {
            false
        }
        else
        {
            lhs.conditions.lexicographicallyPrecedes(rhs.conditions)
        }
    }
}
