import Generics

extension Compiler.Extension
{
    @frozen public
    struct Signature:Equatable, Hashable, Sendable
    {
        /// The type extended by the relevant extension group.
        public
        let type:Symbol.Scalar
        /// The generic constraints of the relevant extension group.
        /// An empty array represents an unconstrained extension.
        public
        let conditions:[GenericConstraint<Symbol.Scalar>]

        public
        init(_ type:Symbol.Scalar, where conditions:[GenericConstraint<Symbol.Scalar>])
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
