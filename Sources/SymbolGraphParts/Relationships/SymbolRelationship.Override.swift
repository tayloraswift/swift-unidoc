import Symbolics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Override:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbol
        public
        let target:ScalarSymbol
        public
        let origin:ScalarSymbol?

        @inlinable public
        init(_ source:ScalarSymbol, of target:ScalarSymbol, origin:ScalarSymbol? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.Override
{
    public
    func validate(source phylum:ScalarPhylum) -> Bool
    {
        switch phylum
        {
        case .actor:                return false
        case .associatedtype:       return true
        case .case:                 return false
        case .class:                return false
        case .deinitializer:        return false
        case .enum:                 return false
        case .func(nil):            return false
        case .func(_?):             return true
        //  Protocol init can override another requirement.
        case .initializer:          return true
        case .operator:             return true
        case .protocol:             return false
        case .struct:               return false
        case .subscript:            return true
        case .typealias:            return false
        case .var(nil):             return false
        case .var(_?):              return true
        }
    }
}
extension SymbolRelationship.Override:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (override: \(self.source), of: \(self.target))
        """
    }
}
