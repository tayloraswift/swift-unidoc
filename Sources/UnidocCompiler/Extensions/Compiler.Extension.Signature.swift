import Generics
import Symbols

extension Compiler.Extension
{
    @frozen public
    struct Signature:Equatable, Hashable, Sendable
    {
        /// The generic constraints of the relevant extension group.
        /// An empty array represents an unconstrained extension.
        public
        let conditions:[GenericConstraint<ScalarSymbol>]
        /// The type extended by the relevant extension group.
        public
        let extended:Compiler.ExtendedType
        public
        let culture:Int

        public
        init(_ culture:Int, _ extended:Compiler.ExtendedType,
            where conditions:[GenericConstraint<ScalarSymbol>])
        {
            self.conditions = conditions
            self.culture = culture
            self.extended = extended
        }
    }
}
extension Compiler.Extension.Signature:Comparable
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
