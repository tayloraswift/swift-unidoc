import Generics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Conformance:Equatable, Hashable, Sendable
    {
        public
        let conditions:[GenericConstraint<ScalarSymbol>]
        public
        let source:UnifiedSymbol
        public
        let target:ScalarSymbol
        public
        let origin:ScalarSymbol?

        @inlinable public
        init(of source:UnifiedSymbol,
            to target:ScalarSymbol,
            where conditions:[GenericConstraint<ScalarSymbol>]?,
            origin:ScalarSymbol? = nil)
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
