extension SymbolRelationship
{
    @frozen public
    struct Membership:Equatable, Hashable, Sendable
    {
        public
        let source:UnifiedSymbolResolution
        public
        let target:UnifiedSymbolResolution
        public
        let origin:ScalarSymbolResolution?

        @inlinable public
        init(of source:UnifiedSymbolResolution,
            in target:UnifiedSymbolResolution,
            origin:ScalarSymbolResolution? = nil)
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
    var virtuality:SymbolGraph.Scalar.Virtuality? { nil }

    @inlinable public
    var scope:UnifiedSymbolResolution? { self.target }

    public
    func validate(source phylum:SymbolGraph.Scalar.Phylum) -> Bool
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
