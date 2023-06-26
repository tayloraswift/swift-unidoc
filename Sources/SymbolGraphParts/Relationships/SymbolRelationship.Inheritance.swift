import Symbols
import Unidoc

extension SymbolRelationship
{
    @frozen public
    struct Inheritance:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Decl
        public
        let target:Symbol.Decl
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(by source:Symbol.Decl, of target:Symbol.Decl, origin:Symbol.Decl? = nil)
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
    func validate(source phylum:Unidoc.Decl) -> Bool
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
