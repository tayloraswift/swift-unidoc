extension SymbolRelationship
{
    @frozen public
    struct Conformance:Equatable, Hashable, Sendable
    {
        public
        let conditions:[GenericConstraint<ScalarSymbolResolution>]
        public
        let source:UnifiedSymbolResolution
        public
        let target:ScalarSymbolResolution

        @inlinable public
        init(of source:UnifiedSymbolResolution,
            to target:ScalarSymbolResolution,
            where conditions:[GenericConstraint<ScalarSymbolResolution>]?)
        {
            self.conditions = conditions ?? []
            self.source = source
            self.target = target
        }
    }
}
