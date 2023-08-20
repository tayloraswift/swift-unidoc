import Symbols
import Unidoc

extension Symbol
{
    @frozen public
    struct MemberRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol
        public
        let target:Symbol
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(_ source:Symbol, in target:Symbol, origin:Symbol.Decl? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension Symbol.MemberRelationship:NestingRelationship
{
    @inlinable public
    var kinks:Unidoc.Decl.Kinks { [] }

    @inlinable public
    var scope:Symbol { self.target }

    public
    func validate(source phylum:Unidoc.Decl) -> Bool
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
        case .protocol:             return true // SE-404
        case .struct:               return true
        case .subscript:            return true
        case .typealias:            return true
        case .var(nil):             return false
        case .var(_?):              return true
        }
    }
}
extension Symbol.MemberRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (member: \(self.source), of: \(self.target))
        """
    }
}
