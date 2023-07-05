import Signatures
import Symbols

extension Compiler
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
extension Compiler.ExtensionSignature:Comparable
{
    public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        if      (lhs.culture, lhs.extended) < (rhs.culture, rhs.extended)
        {
            return true
        }
        else if (lhs.culture, lhs.extended) > (rhs.culture, rhs.extended)
        {
            return false
        }
        else
        {
            return lhs.conditions.lexicographicallyPrecedes(rhs.conditions)
        }
    }
}
