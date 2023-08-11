import Symbols
import Unidoc

extension Symbol
{
    @frozen public
    struct OverrideRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Decl
        public
        let target:Symbol.Decl
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(_ source:Symbol.Decl, of target:Symbol.Decl, origin:Symbol.Decl? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension Symbol.OverrideRelationship:SuperformRelationship
{
    @inlinable public
    var kinks:Unidoc.Decl.Kinks { [.override] }

    public
    func validate(source phylum:Unidoc.Decl) -> Bool
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
extension Symbol.OverrideRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (override: \(self.source), of: \(self.target))
        """
    }
}
