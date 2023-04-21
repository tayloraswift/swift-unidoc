extension SymbolRelationship
{
    @frozen public
    struct Requirement:Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution
        public
        let origin:ScalarSymbolResolution?
        public
        let optional:Bool

        init(_ source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution,
            origin:ScalarSymbolResolution? = nil,
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
    var virtuality:SymbolGraph.Scalar.Virtuality?
    {
        self.optional ? .optional : .required
    }

    @inlinable public
    var scope:UnifiedSymbolResolution?
    {
        .scalar(self.target)
    }

    public
    func validate(source phylum:SymbolGraph.Scalar.Phylum) -> Bool
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
