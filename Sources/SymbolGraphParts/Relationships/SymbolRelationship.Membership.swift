import Symbolics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Membership:Equatable, Hashable, Sendable
    {
        public
        let source:Symbol
        public
        let target:Symbol
        public
        let origin:Symbol.Scalar?

        @inlinable public
        init(of source:Symbol, in target:Symbol, origin:Symbol.Scalar? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.Membership:NestingRelationship
{
    @inlinable public
    var virtuality:ScalarPhylum.Virtuality? { nil }

    @inlinable public
    var scope:Symbol? { self.target }

    public
    func validate(source phylum:ScalarPhylum) -> Bool
    {
        switch phylum
        {
        case .actor:                return true
        case .associatedtype:       return true
        case .case:                 return true
        case .class:                return true
        case .deinitializer:        return true
        case .enum:                 return true
        case .func(nil):            return false
        case .func(_?):             return true
        case .initializer:          return true
        case .operator:             return true
        case .protocol:             return false
        case .struct:               return true
        case .subscript:            return true
        case .typealias:            return true
        case .var(nil):             return false
        case .var(_?):              return true
        }
    }
}
extension SymbolRelationship.Membership:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (member: \(self.source), of: \(self.target))
        """
    }
}
