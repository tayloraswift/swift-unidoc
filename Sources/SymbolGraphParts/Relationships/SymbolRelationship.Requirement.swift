import Symbolics
import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Requirement:Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbol
        public
        let target:ScalarSymbol
        public
        let origin:ScalarSymbol?
        public
        let optional:Bool

        init(_ source:ScalarSymbol,
            of target:ScalarSymbol,
            origin:ScalarSymbol? = nil,
            optional:Bool = false)
        {
            self.source = source
            self.target = target
            self.origin = origin
            self.optional = optional
        }
    }
}
extension SymbolRelationship.Requirement:NestingRelationship
{
    @inlinable public
    var aperture:ScalarAperture?
    {
        self.optional ? .requiredOptionally : .required
    }

    @inlinable public
    var scope:UnifiedSymbol?
    {
        .scalar(self.target)
    }

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
extension SymbolRelationship.Requirement:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (\(self.optional ? "optional " : "")requirement: \(self.source), of: \(self.target))
        """
    }
}
