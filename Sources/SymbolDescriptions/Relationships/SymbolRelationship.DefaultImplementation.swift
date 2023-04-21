extension SymbolRelationship
{
    @frozen public
    struct DefaultImplementation:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution
        public
        let origin:ScalarSymbolResolution?

        @inlinable public
        init(_ source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution,
            origin:ScalarSymbolResolution? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.DefaultImplementation
{
    public
    func validate(source phylum:SymbolGraph.Scalar.Phylum) -> Bool
    {
        switch phylum
        {
        case .actor:                return false
        case .associatedtype:       return false
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
        case .typealias:            return true
        case .var(nil):             return false
        case .var(_?):              return true
        }
    }
}
extension SymbolRelationship.DefaultImplementation:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (default implementation: \(self.source), of: \(self.target))
        """
    }
}
