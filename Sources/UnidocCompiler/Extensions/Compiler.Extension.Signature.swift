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
        public
        let culture:Int
        /// The type extended by the relevant extension group.
        public
        let type:ScalarSymbol

        public
        init(_ culture:Int, _ type:ScalarSymbol,
            where conditions:[GenericConstraint<ScalarSymbol>])
        {
            self.conditions = conditions
            self.culture = culture
            self.type = type
        }
    }
}
extension Compiler.Extension.Signature:Comparable
{
    public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        if      (lhs.culture, lhs.type) < (rhs.culture, rhs.type)
        {
            return true
        }
        else if (lhs.culture, lhs.type) > (rhs.culture, rhs.type)
        {
            return false
        }
        else
        {
            return lhs.conditions.lexicographicallyPrecedes(rhs.conditions)
        }
    }
}
