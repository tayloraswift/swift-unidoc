import Generics
import Symbols

extension Compiler.Extension
{
    @frozen public
    struct Signature:Equatable, Hashable, Sendable
    {
        /// The type extended by the relevant extension group.
        public
        let type:ScalarSymbol
        /// The generic constraints of the relevant extension group.
        /// An empty array represents an unconstrained extension.
        public
        let conditions:[GenericConstraint<ScalarSymbol>]

        public
        init(_ type:ScalarSymbol, where conditions:[GenericConstraint<ScalarSymbol>])
        {
            self.type = type
            self.conditions = conditions
        }
    }
}
extension Compiler.Extension.Signature:Comparable
{
    public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        if      lhs.type < rhs.type
        {
            return true
        }
        else if lhs.type > rhs.type
        {
            return false
        }
        else
        {
            return lhs.conditions.lexicographicallyPrecedes(rhs.conditions)
        }
    }
}
