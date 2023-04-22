import Generics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Conformance:Equatable, Hashable, Sendable
    {
        public
        let conditions:[GenericConstraint<Symbol.Scalar>]
        public
        let source:Symbol
        public
        let target:Symbol.Scalar
        public
        let origin:Symbol.Scalar?

        @inlinable public
        init(of source:Symbol,
            to target:Symbol.Scalar,
            where conditions:[GenericConstraint<Symbol.Scalar>]?,
            origin:Symbol.Scalar? = nil)
        {
            self.conditions = conditions ?? []
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.Conformance:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (conformance: \(self.source), to: \(self.target))
        """
    }
}
