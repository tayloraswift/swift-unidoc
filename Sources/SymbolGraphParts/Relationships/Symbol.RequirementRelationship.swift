import Symbols

extension Symbol
{
    @frozen public
    struct RequirementRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Decl
        public
        let target:Symbol.Decl
        public
        let origin:Symbol.Decl?
        public
        let optional:Bool

        init(_ source:Symbol.Decl,
            of target:Symbol.Decl,
            origin:Symbol.Decl? = nil,
            optional:Bool = false)
        {
            self.source = source
            self.target = target
            self.origin = origin
            self.optional = optional
        }
    }
}
extension Symbol.RequirementRelationship:NestingRelationship
{
    @inlinable public
    var kinks:Phylum.Decl.Kinks
    {
        self.optional ? [.requiredOptionally] : [.required]
    }

    @inlinable public
    var scope:Symbol.USR
    {
        .scalar(self.target)
    }

    public
    func validate(source phylum:Phylum.Decl) -> Bool
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
        case .macro:                return false
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
extension Symbol.RequirementRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (\(self.optional ? "optional " : "")requirement: \(self.source), of: \(self.target))
        """
    }
}
