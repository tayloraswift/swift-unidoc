import Symbolics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Inheritance:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Scalar
        public
        let target:Symbol.Scalar
        public
        let origin:Symbol.Scalar?

        @inlinable public
        init(by source:Symbol.Scalar, of target:Symbol.Scalar, origin:Symbol.Scalar? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.Inheritance
{
    public
    func validate(source phylum:ScalarPhylum) -> Bool
    {
        switch phylum
        {
        case .actor:                return false
        case .associatedtype:       return false
        case .case:                 return false
        case .class:                return true
        case .deinitializer:        return false
        case .enum:                 return false
        case .func:                 return false
        case .initializer:          return false
        case .operator:             return false
        case .protocol:             return true
        case .struct:               return false
        case .subscript:            return false
        case .typealias:            return false
        case .var:                  return false
        }
    }
}
extension SymbolRelationship.Inheritance:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (inheritance by: \(self.source), of: \(self.target))
        """
    }
}
