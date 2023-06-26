import Generics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Conformance:Equatable, Hashable, Sendable
    {
        public
        let conditions:[GenericConstraint<Symbol.Decl>]
        public
        let source:Symbol
        public
        let target:Symbol.Decl
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(of source:Symbol,
            to target:Symbol.Decl,
            where conditions:[GenericConstraint<Symbol.Decl>]?,
            origin:Symbol.Decl? = nil)
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
