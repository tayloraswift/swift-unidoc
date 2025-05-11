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

        @inlinable public
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

    public
    func validate(source phylum:Phylum.Decl) -> Bool
    {
        switch phylum
        {
        case .actor:                false
        case .associatedtype:       true
        case .case:                 false
        case .class:                false
        case .deinitializer:        false
        case .enum:                 false
        case .func(nil):            false
        case .func(_?):             true
        case .initializer:          true
        case .macro:                false
        case .operator:             true
        case .protocol:             false
        case .struct:               false
        case .subscript:            true
        case .typealias:            false
        case .var(nil):             false
        case .var(_?):              true
        }
    }
}
extension Symbol.RequirementRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        /\(self.source) REQUIRED BY \(self.target) \
        (\(self.origin == nil ? 0 : 1) origin(s), optional: \(self.optional))/
        """
    }
}
